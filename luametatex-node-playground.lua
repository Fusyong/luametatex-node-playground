userdata = userdata or {}

-----------------汉字左旋90度旋转----------------------
local glyph_id = node.id("glyph")
local hlist_id = node.id("hlist")
local vlist_id = node.id("vlist")
local fontdata = fonts.hashes.identifiers -- assumes generic font loader
--判断是不是汉子（是否需要直排）
local function is_vertical(c)
    -- 常用的汉字编码范围，还有更多
    return c >= 0x04E00 and c <= 0x09FFF
end

-- 处理程序，输出一个盒子号码
function userdata.go_vertical(head)
    --local box = tex.getbox(boxnumber)
    --local n = box.list
    local n = head
    while n do
        --嵌套序列的开头???
        if n.id == hlist_id or n.id == vlist_id then
            print("\n---------------n----------------")
            print(n, nodes.toutf(n), nodes.toutf(n.list))
            print(n.next, nodes.toutf(n.next))
            --userdata.go_vertical(n.list) -- 无效
            n.orientation = 0x003 --旋转整个盒子
        end
        -- 字模且是汉字
        if n.id == glyph_id and is_vertical(n.char) then
            local o = .2 * fontdata[n.font].parameters.xheight
            local prev, next = n.prev, n.next
            n.next, n.prev = nil, nil
            local l = nodes.new("hlist")
            l.list = n
            local w, h, d = n.width, n.height, n.depth
            if prev then
                prev.next, l.prev = l, prev
            else
                --box.list = l
                --n = l
            end
            if next then
                l.next, next.prev = next, l
            end
            l.width, l.height, l.depth = h + d + o, w, 0
            l.orientation = 0x003
            l.xoffset, l.yoffset = o/2, -o/2
            l.hoffset, l.doffset = h, d - o
            n = next
        --跳过结点
        else
            n = n.next
        end
    end
end

--把`userdata.go_vertical`函数挂载到processors回调的normalizers类别中。
nodes.tasks.appendaction("processors", "after", "userdata.go_vertical")
--先停用
nodes.tasks.disableaction("processors", "userdata.go_vertical")