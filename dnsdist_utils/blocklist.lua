
local blcklist = {}

function blcklist.load_cdb(arg)
  kvs = newCDBKVStore(arg.file, arg.refresh)
  addAction(KeyValueStoreLookupRule(kvs, KeyValueLookupKeyQName(false)), SpoofAction({"127.0.0.1", "::1"}), {name="blocklist-cdb"})
  mvRuleToTop()
end

function blcklist.disable_cdb()
  rmRule("blocklist-cdb")
end

return blcklist
