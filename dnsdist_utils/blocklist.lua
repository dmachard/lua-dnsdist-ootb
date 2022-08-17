
local blcklist = {}

function blcklist.load_cdb(arg)
  kvs = newCDBKVStore(arg.file, arg.refresh)
  addAction(AllRule(), KeyValueStoreLookupAction(kvs, KeyValueLookupKeyQName(false), 'policy'))
end

function blcklist.add_actions(arg)
  if arg.spoof == "nxdomain" then
    addAction(TagRule('policy', 'blocked'), RCodeAction(DNSRCode.NXDOMAIN))
  end
  if arg.spoof == "localhost" then
    addAction(TagRule('policy', 'blocked'), SpoofAction({"127.0.0.1", "::1"}))
  end
end

return blcklist
