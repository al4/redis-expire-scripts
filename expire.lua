local modified={};

for i,k in ipairs(KEYS) do
    local ttl=redis.call('ttl', k);
    if ttl == -1 then
        redis.call('EXPIRE', k, 60)
        modified[#modified + 1] = k;
    end
end

return modified;
