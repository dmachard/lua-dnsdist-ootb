
local blcklist = {
	smn = newSuffixMatchNode(),
  file = "/etc/dnsdist/blocklist.txt"
}

function blcklist.load(arg)
  if arg.file then
    blcklist.file = arg.file
  end

  for l in io.lines(blcklist.file) do
    if l ~= "" then
      if l:find("^#") == nil then
        blcklist.smn:add(newDNSName(l))
      end
    end
  end
  addAction(SuffixMatchNodeRule(blcklist.smn, true), SpoofAction({"127.0.0.1", "::1"}))
end

function blcklist.reload()
  -- disable rule
  blcklist.disable()
  
  -- clear
  blcklist.smn = newSuffixMatchNode()
  collectgarbage()
  
  -- load
  blcklist.load{file=blcklist.file}
end

return blcklist
