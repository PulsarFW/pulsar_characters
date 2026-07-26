local _noUpdate = { "Source", "User", "_id", "ID", "First", "Last", "Phone", "DOB", "Gender", "TempJob", "Ped", "MDTHistory", "Parole", "Preview", "Team", "LSUNDGBan", "MDTSuspension", "Profiles", "TempJob" }

local _saving = {}
local _tableReady = false

-- Real columns for anything actually queried across rows; rest stays in `data`.
function EnsureCharactersTable(callback)
	if _tableReady then
		if callback then
			callback()
		end
		return
	end
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `characters` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `account` BIGINT UNSIGNED NOT NULL, `sid` BIGINT UNSIGNED NULL, `deleted` TINYINT(1) NOT NULL DEFAULT 0, `phone` VARCHAR(20) NULL, `crypto_wallet` VARCHAR(20) NULL, `data` JSON NOT NULL, INDEX `idx_account` (`account`), INDEX `idx_sid` (`sid`), INDEX `idx_deleted` (`deleted`), INDEX `idx_phone` (`phone`), INDEX `idx_crypto_wallet` (`crypto_wallet`))",
		nil,
		function()
			plsr.Database:Query(
				"ALTER TABLE `characters` ADD COLUMN IF NOT EXISTS `phone` VARCHAR(20) NULL, ADD COLUMN IF NOT EXISTS `crypto_wallet` VARCHAR(20) NULL, ADD INDEX IF NOT EXISTS `idx_phone` (`phone`), ADD INDEX IF NOT EXISTS `idx_crypto_wallet` (`crypto_wallet`)",
				nil,
				function()
					_tableReady = true
					if callback then
						callback()
					end
				end
			)
		end
	)
end

function StoreData(source)
	if _saving[source] then
		return
	end
	_saving[source] = true
	local char = plsr.Fetch:CharacterSource(source)
	if char ~= nil then
		local data = char:GetData()
		local cId = data.ID
		local account = data.User
		local sid = data.SID
		local deleted = data.Deleted or false
		local cryptoWallet = data.CryptoWallet

		for k, v in ipairs(_noUpdate) do
			data[v] = nil
		end

		local ped = GetPlayerPed(source)
		if ped > 0 then
			data.HP = GetEntityHealth(ped)
			data.Armor = GetPedArmour(ped)
		end

		if data.States then
			local s = {}
			for k, v in ipairs(data.States) do
				if string.sub(v, 1, string.len("SCRIPT")) ~= "SCRIPT" then
					table.insert(s, v)
				end
			end
			data.States = s
		end

		data.LastPlayed = os.time() * 1000

		plsr.Logger:Info("Characters", string.format("Saving Character %s", cId), { console = true })

		EnsureCharactersTable(function()
			-- fetch+merge instead of overwrite, since `data` here is missing the _noUpdate fields
			plsr.Database:Single("SELECT `data` FROM `characters` WHERE `id` = ?", { cId }, function(success, row)
				local existing = {}
				if success and row ~= nil then
					local ok, decoded = pcall(json.decode, row.data)
					if ok and type(decoded) == "table" then
						existing = decoded
					end
				end

				for k, v in pairs(data) do
					existing[k] = v
				end

				plsr.Database:Update(
					"UPDATE `characters` SET `account` = ?, `sid` = ?, `deleted` = ?, `crypto_wallet` = ?, `data` = ? WHERE `id` = ?",
					{ account, sid, deleted, cryptoWallet, json.encode(existing), cId },
					function()
						_saving[source] = false
					end
				)
			end)
		end)
	end
end
