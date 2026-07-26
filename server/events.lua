RegisterServerEvent('Characters:Server:Spawning', function()
    plsr.Middleware:TriggerEvent("Characters:Spawning", source)
end)

RegisterServerEvent('Ped:LeaveCreator', function()
    local char = plsr.Fetch:CharacterSource(source)
    if char ~= nil then
        if char:GetData("New") then
            char:SetData("New", false)
        end
    end
end)