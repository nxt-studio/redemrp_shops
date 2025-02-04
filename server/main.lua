local Items = exports.inventory:ItemsList()

local ShopItems = {}

Citizen.CreateThread(function()
    LoadShop()
end)

function LoadShop()
    ShopItems = {}

    for k,v in pairs(ShopItemsData) do
        if ShopItems[v.store] == nil then
            ShopItems[v.store] = {}
        end

        local name = v.item

        local item = Items[name]
        if item and item.label then
            name = item.label
        end

        table.insert(ShopItems[v.store], {
            label = name,
            item  = v.item,
            price = v.price,
            object = v.object,
            limit = 32,
        })
    end
end

function GetPrice(ItemName , Zone)
	for k,v in pairs(ShopItems[Zone]) do
        if v.item == ItemName then
            return v.price
        end
    end
    return 0
end

RegisterNetEvent('redemrp_shops:RequestItems', function()
    local _source = source
    TriggerClientEvent('redemrp_shops:GetItems', _source, ShopItems)
end)

RegisterNetEvent('redemrp_shops:BuyItem', function(itemName, amount , zone)
    local _source = source
    local amount_ = math.floor(amount)

	if amount_ < 0 then return end

	local ItemPrice = GetPrice(itemName , zone)
	local TotalPrice = ItemPrice * amount_

    local Item = Items[itemName]

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            if user.getMoney() >= TotalPrice then

                if not exports.inventory:canCarryItem(_source, itemName, amount_) then
                    TriggerClientEvent("redemrp_notification:start", _source, "You don't have enough space!", 3, "error")
                else
                    if exports.inventory:AddItem(_source, itemName, amount_) then
                        user.removeMoney(TotalPrice)

                        local name = Item.label

                        TriggerClientEvent("pNotify:SendNotification", _source , {
                            text = "<img src='nui://redemrp_inventory/html/items/"..itemName..".png' height='40' width='40' style='float:left; margin-bottom:10px; margin-left:20px;' />You Bought: ".. name.."<br>+"..tonumber(amount_),
                            type = "success",
                            timeout = math.random(2000, 3000),
                            layout = "centerLeft",
                            queue = "right"
                        })
                    end
                end

            else
                local missingMoney = TotalPrice - user.getMoney()
                TriggerClientEvent("redemrp_notification:start", _source, "You don't have enough money: "..missingMoney, 3, "error")
            end
    end)
end)
