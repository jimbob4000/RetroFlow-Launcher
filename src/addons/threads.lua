Threads = {}
Threads.Generation = 0

local Queue = {}
local Task = nil

local Trash = {
    Type = nil,
    Garbadge = nil
}

local uniques = {}

function Threads.bumpGeneration()
    Threads.Generation = Threads.Generation + 1
end

local function valid_image_handle(image)
    return type(image) == "number" and image ~= 0 and image ~= 1
end

function Threads.update()
    if (#Queue == 0 and not Task) or System.getAsyncState() == 0 then
        return
    end
    if not Task then
        local new_order = {}
        for _, v in ipairs(Queue) do
            if v.Type == "Skip" then
            else
                new_order[#new_order + 1] = v
            end
        end
        Queue = new_order
        if #Queue == 0 then
            return
        end
        Task = table.remove(Queue, 1)
        if Task.Type == "ImageLoad" then
            if Task.Path then
                local Task_Path_GSub = Task.Path:gsub("%%", "%%%%")
                Graphics.loadImageAsync(Task_Path_GSub)
            else
                uniques[Task.UniqueKey] = nil
                Task = nil
            end
        end
    else
        local f_save = function()
            Trash.Type = Task.Type
            Trash.Link = Task.Link
            if Task.Type == "ImageLoad" then
                if System.doesFileExist(Task.Path) then
                    local result = System.getAsyncResult()
                    if Task.Generation == Threads.Generation then
                        Task.Table[Task.Index] = result
                    elseif valid_image_handle(result) then
                        Graphics.freeImage(result)
                    end
                else
                    error("File not found?")
                end
            elseif Task.Type == "Skip" then
                
            end
            uniques[Task.UniqueKey] = nil
            Task = nil
        end
        local TempTask = Task
        local success, err = pcall(f_save)
        if success then
            if Task == nil then
                if TempTask.OnComplete then
                    TempTask.OnComplete()
                end
            end
        else
            Task.Retry = Task.Retry - 1
            if Task.Retry > 0 then
                table.insert(Queue, Task)
            else
                uniques[Task.UniqueKey] = nil
            end
            Task = nil
        end
    end
    if Trash.Garbadge then
        if Trash.Type == "ImageLoad" then
            if valid_image_handle(Trash.Garbadge) then
                Graphics.freeImage(Trash.Garbadge)
            end
        end
        Trash.Garbadge = nil
    end
end

function Threads.clear()
    Threads.bumpGeneration()
    Queue = {}
    uniques = {}
    if Task ~= nil then
        Task.Table = Trash
        Task.Index = "Garbadge"
    end
end

---@param UniqueKey string
---@param T table
---@return boolean
---Adds task to threads
function Threads.addTask(UniqueKey, T)
    if UniqueKey and uniques[UniqueKey] or not UniqueKey then
        return false
    end
    local newTask = {
        Type = T.Type,
        Table = T.Table,
        Index = T.Index,
        Path = T.Path,
        Retry = 1,
        UniqueKey = UniqueKey,
        Generation = T.Generation or Threads.Generation
    }
    Queue[#Queue + 1] = newTask
    uniques[UniqueKey] = newTask
    return true
end

---@param UniqueKey string
---Removes task by `UniqueKey`
function Threads.remove(UniqueKey)
    if uniques[UniqueKey] then
        if Task == uniques[UniqueKey] then
            Task.Table, Task.Index = Trash, "Garbadge"
        else
            uniques[UniqueKey].Type = "Skip"
        end
        uniques[UniqueKey] = nil
    end
end

---@param UniqueKey string
---Checks if task is in order by `UniqueKey`
function Threads.check(UniqueKey)
    return uniques[UniqueKey] ~= nil
end
