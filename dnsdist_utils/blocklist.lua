
local blcklist = {
	smn = newSuffixMatchNode()
}

function blcklist.load(arg)
  for l in io.lines(arg.file) do
    if l ~= "" then
      if l:find("^#") == nil then
        blcklist.smn:add(newDNSName(l))
      end
    end
  end
  addAction(SuffixMatchNodeRule(blcklist.smn, true), SpoofAction({"127.0.0.1", "::1"}))
end

function blcklist.reload(arg)
end

return blcklist
