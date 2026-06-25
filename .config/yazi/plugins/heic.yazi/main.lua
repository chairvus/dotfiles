local M = {}

function M:peek(job)
    local cache = ya.file_cache(job)
    if not cache then return end

    local cache_png = tostring(cache) .. ".png"

    if not fs.cha(Url(cache_png)) then
        Command("magick")
            :arg(tostring(job.file.url))
            :arg("-strip")
            :arg(cache_png)
            :status()
    end

    ya.image_show(Url(cache_png), job.area)
end

function M:preload(job)
    local cache = ya.file_cache(job)
    if not cache then return 1 end

    local cache_png = tostring(cache) .. ".png"
    if fs.cha(Url(cache_png)) then return 1 end

    local status = Command("magick")
        :arg(tostring(job.file.url))
        :arg("-strip")
        :arg(cache_png)
        :status()

    return (status and status.success) and 1 or 2
end

function M:seek() end

return M
