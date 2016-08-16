--[[
ComboPointsRedux_Options - LoD option module for ComboPointsRedux
Author: Michael Joseph Murray aka Lyte of Lothar(US)
$Revision: 417 $
$Date: 2016-08-14 14:26:55 +0000 (Sun, 14 Aug 2016) $
Project Version: 2.0.0 beta2
contact: codemaster2010 AT gmail DOT com

Copyright (c) 2007-2012 Michael J. Murray aka Lyte of Lothar(US)
All rights reserved unless otherwise explicitly stated.
]]

local core = LibStub("AceAddon-3.0"):GetAddon("ComboPointsRedux")
local L = LibStub("AceLocale-3.0"):GetLocale("ComboPointsRedux_Options")
local LC = LibStub("AceLocale-3.0"):GetLocale("ComboPointsRedux")
local format = string.format

--upvalue some tables used in the 'select' options
local stratas = {["FULLSCREEN"] = "Fullscreen", ["HIGH"] = "High", ["MEDIUM"] = "Medium", ["LOW"] = "Low", ["BACKGROUND"] = "Background",}
local symbols = {
	square = L["Square"],
	circle = L["Circle"],
	diamond = L["Diamond"],
	Triangle = L["Triangle"],
	["kanji-strength"] = L["Kanji - Strength"],
	["kanji-strength-invert"] = L["Kanji - Strength (Inverted)"],
	["kanji-death"] = L["Kanji - Death"],
	["kanji-death-invert"] = L["Kanji - Death (Inverted)"],
	["kanji-faith"] = L["Kanji - Faith"],
	["kanji-faith-invert"] = L["Kanji - Faith (Inverted)"],
	Shard = GetSpellInfo(87388),
	Ember = GetSpellInfo(108647),
	["Paladin_Holyrune"] = L["Holy Rune"],
	["Paladin_SoT"] = L["Crossed Swords"],
	["Rogue_Point"] = L["Rogue Point"],
	["Rogue_Sword"] = L["Rogue's Sword"],
	["DeathKnight_BoneShield"] = L["Bone Shield"],
	["DeathKnight_ShadowInfusion"] = L["Shadow Infusion"],
	["Druid_Lacerate"] = L["Lacerate"],
	["Druid_LunarShower"] = L["Lunar Shower"],
	["Druid_LunarShower2"] = L["Lunar Shower (Alternate)"],
	["Hunter_Bullseye"] = L["Bulls-eye"],
	["Mage_ArcaneBlast"] = L["Arcane Blast"],
	["Priest_DarkEvangelism"] = L["Dark Evangelism"],
	["Priest_Evangelism"] = L["Evangelism"],
	["Priest_Serendipity"] = L["Serendipity"],
	["Priest_Serendipity2"] = L["Serendipity (Alternate)"],
	["Priest_ShadowOrb"] = GetSpellInfo(77487),
	["Rogue_DeadlyPoison"] = GetSpellInfo(2823),
	["Rogue_Guile"] = GetSpellInfo(84654),
	["Shaman_Fulmination"] = GetSpellInfo(88766),
	["Shaman_Maelstrom"] = GetSpellInfo(53817),
	["Shaman_Tidalwave"] = GetSpellInfo(53390),
	["Warrior_MeatCleaver"] = GetSpellInfo(85739),
	["Warrior_Thunderstruck"] = GetSpellInfo(87096),
	["Shard (Alt)"] = L["Soul Shard (Alternate)"],
	BloodRune = L["Blood Rune"],
	DeathRune = L["Death Rune"],
	FrostRune = L["Frost Rune"],
	UnholyRune = L["Unholy Rune"],
	TouchofKarma = GetSpellInfo(124280),
}

local growthdirections = {right = "Right", left = "Left", up = "Up", down = "Down"}
local outlineStyles = {NONE = _G["NONE"], OUTLINE = L["Outline"], THICKOUTLINE = L["Thick Outline"]}
local flashModes = {STRICT = L["STRICT"], RELAXED = L["RELAXED"]}
local modes = {icon = "Icon Mode", frame = "Frame Mode"}

local opts = {
	type = 'group',
	args = {},
}

--generate the Core options
opts.args["core"] = {
	type = "group",
	name = "Core",
	order = 1,
	args = {
		locked = {
			type = "toggle",
			name = L["Lock"],
			desc = L["Lock all the frames in place, preventing movement and hiding the background."],
			descStyle = "inline",
			width = "full",
			order = 1,
			get = function() return core.db.profile.locked end,
			set = function()
				core.db.profile.locked = not core.db.profile.locked
				for name, module in core:IterateModules() do
					if module:IsEnabled() then
						if not core.db.profile.locked then
							if module.graphics then
								module.graphics:SetBackdropColor(1,1,1,1)
								module.graphics:EnableMouse(true)
								module.graphics:SetMovable(true)
								--module.graphics.points[1]:Show()
							end
							if module.text then	
								module.text:SetBackdropColor(1,1,1,1)
								module.text:EnableMouse(true)
								module.text:SetMovable(true)
								module.text.count:SetText(module.abbrev)
							end
						else
							if module.graphics then
								module.graphics:EnableMouse(false)
								module.graphics:SetMovable(false)
								module.graphics:SetBackdropColor(1,1,1,0)
								--module.graphics.points[1]:Hide()
							end
							if module.text then
								module.text:EnableMouse(false)
								module.text:SetMovable(false)
								module.text:SetBackdropColor(1,1,1,0)
								module.text.count:SetText("")
							end
						end
					end
				end
			end,
		},
	},
}

--generate the enable/disable options per module
for name, module in core:IterateModules() do
	opts.args.core.args[name.."toggle"] = {
		type = "toggle",
		name = format(L["%s Module enabled"], module.displayName),
		desc = format(L["Select whether or not the %s module is enabled."], module.displayName),
		descStyle = "inline",
		width = "full",
		order = 2,
		get = function()
			return core.db.profile.modules[name].enabled
		end,
		set = function(info, value)
			core.db.profile.modules[name].enabled = value
			if value then
				module:Enable()
			else
				module:Disable()
			end
		end,
	}
end

--generate options for each registered module
local handlers = {}
local i = 2
for name, module in core:IterateModules() do
	handlers[name] = {
		Get = function(self, info, ...)
			if info.type == "color" then
				if info.arg == "textColor" then
					return unpack(core.db.profile.modules[name][info.arg])
				elseif info.arg == "screenFlashColor" then
					return unpack(core.db.profile.modules[name][info.arg])
				else
					return unpack(core.db.profile.modules[name].colors[info.arg])
				end
			else
				return core.db.profile.modules[name][info.arg]
			end
		end,
		Set = function(self, info, ...)
			if info.type == "color" then
				if info.arg == "textColor" then
					local color = core.db.profile.modules[name][info.arg]
					color[1], color[2], color[3] = ...
				elseif info.arg == "screenFlashColor" then
					local color = core.db.profile.modules[name][info.arg]
					color[1], color[2], color[3] = ...
				else
					local color = core.db.profile.modules[name].colors[info.arg]
					color[1], color[2], color[3] = ...
				end
			else
				core.db.profile.modules[name][info.arg] = ...
			end
			core:UpdateSettings(name)
		end,
		SetPosition = function(self, info, ...)
			core.db.profile.modules[name][info.arg] = ...
			core:UpdatePositions(name)
		end,
        SetAndUpdate = function(self, info, ...)
            core.db.profile.modules[name][info.arg] = ...
            module:Update()
        end,
	}
	
	opts.args[name] = {
		type = "group",
		name = module.displayName,
		handler = handlers[name],
		disabled = function() return not core.db.profile.modules[name].enabled end,
		order = i,
		args = {
			disablegraphics = {
				type = "toggle",
				name = L["Disable Graphics"],
				desc = L["Select whether or not to show this module's graphics."],
				descStyle = "inline",
				width = "full",
				arg = "disableGraphics",
				get = "Get",
				set = function(info, value)
					core.db.profile.modules[name].disableGraphics = value
					if value then
						module.graphics:Hide()
					else
						if not module.graphics then
							module.graphics = core:MakeGraphicsFrame(name, module.MAX_POINTS)
						end
						module.graphics:Show()
					end
				end,
				order = 1,
			},
			disabletext = {
				type = "toggle",
				name = L["Disable Text"],
				desc = L["Select whether or not to show this module's text counter."],
				descStyle = "inline",
				width = "full",
				arg = "disableText",
				get = "Get",
				set = function(info, value)
					core.db.profile.modules[name].disableText = value
					if value then
						module.text:Hide()
					else
						if not module.text then
							module.text = core:MakeTextFrame(name)
						end
						module.text:Show()
					end
				end,
				order = 2,
			},
			graphics = {
				type = "group",
				name = LC["%s Graphics"]:format(module.displayName),
				inline = true,
				order = 4,
				disabled = function() return core.db.profile.modules[name].disableGraphics end,
				args = {
					oneColor = {
						type = 'color',
						name = format(L["%d |4Point:Points;"], 0),
						desc = format(L["Set the color to be used when you have %d |4point:points;."], 0),
						arg = 0,
						get = "Get",
						set = "Set",
						order = 1,
					},
					iconStyle = {
						type = "select",
						name = L["Icon"],
						desc = L["Select the icon to be used for these graphics."],
						arg = "icon",
						get = "Get",
						set = "Set",
						values = symbols,
						order = 10,
					},
					growthdirection = {
						type = "select",
						name = "Growth Direction",
						desc = "Select the growth direction.",
						arg = "growthdirection",
						get = "Get",
						set = "Set",
						values = growthdirections,
						order = 12,
					},
					strata = {
						type = 'select',
						name = L["Graphics Strata"],
						desc = L["Set the strata level of the graphics frame."],
						get = "Get",
						set = "Set",
						arg = "strata",
						values = stratas,
						order = 13,
					},
					clamp = {
						type = 'toggle',
						name = L["Clamp to Screen"],
						desc = L["Prevent this display from being moved off the screen."],
						get = "Get",
						set = "Set",
						arg = "clampedGraphics",
						order = 14,
					},
					alpha = {
						type = 'range',
						name = L["Icon Alpha"],
						desc = L["Set the alpha of the icons."],
						arg = "graphicsAlpha",
						get = "Get",
						set = "Set",
						min = 0.0,
						max = 1.0,
						step = 0.01,
						order = 15,
					},
					emptyPointAlpha = {
						type = 'range',
						name = "Empty Point Alpha",
						desc = "Select the alpha of empty combo points.",
						get = "Get",
						set = "Set",
						arg = "emptyPointAlpha",
						min = 0.0,
						max = 1.0,
						step = 0.01,
						order = 16,
					},
					scale = {
						type = 'range',
						name = L["Scale"],
						desc = L["Set the scale of the icons."],
						arg = "scale",
						get = "Get",
						set = "Set",
						min = 0.1,
						max = 3.5,
						step = 0.001,
						order = 17,
					},
					x = {
						type = 'range',
						name = L["X Position"],
						--desc = L[""],
						arg = "graphicsX",
						get = "Get",
						set = "SetPosition",
						softMin = 0,
						softMax = math.floor(GetScreenWidth()),
						step = 1,
						bigStep = 5,
						order = 18,
					},
					y = {
						type = 'range',
						name = L["Y Position"],
						--desc = L[""],
						arg = "graphicsY",
						get = "Get",
						set = "SetPosition",
						softMin = 0,
						softMax = math.floor(GetScreenHeight()),
						step = 1,
						bigStep = 5,
						order = 19,
					},
					spacing = {
						type = 'range',
						name = L["Icon Spacing"],
						desc = "Set the spacing between the icons.",
						arg = "spacing",
						get = "Get",
						set = "Set",
						min = -2,
						max = 10,
						step = 1,
						order = 10,
					},
					text1 = {
                        order = 30,
                        type = 'description',
                        name = '',
					}, -- Needed a line break. Is there a better way?
					mode = {
						type = "select",
						name = "Mode",
						desc = ".",
						arg = "mode",
						get = "Get",
						set = "Set",
						values = modes,
						order = 31,
					},
					iconmode = {
						type = "group",
						name = "Icon Mode",
						inline = true,
						order = 102,
						disabled = function() return core.db.profile.modules[name].mode == "frame" end,
						args = {
							iconwidth = {
								type = 'range',
								name = "Icon Width",
								desc = "Set the Icon Width when in Icon Mode.",
								arg = "iconwidth",
								get = "Get",
								set = "Set",
								min = 5,
								max = 200,
								step = 0.01,
								order = 1,
							},
							iconheight = {
								type = 'range',
								name = "Icon Height",
								desc = "Set the Icon Height when in Icon Mode.",
								arg = "iconheight",
								get = "Get",
								set = "Set",
								min = 5,
								max = 200,
								step = 0.01,
								order = 2,
							},
						},
					},
					framemode = {
						type = "group",
						name = "Frame Mode",
						inline = true,
						order = 103,
						disabled = function() return core.db.profile.modules[name].mode == "icon" end,
						args = {
							width = {
								type = 'range',
								name = "Frame Width",
								desc = "Set the total width of the icon frame.",
								arg = "width",
								get = "Get",
								set = "Set",
								min = 10,
								max = 500,
								step = 0.01,
								order = 1,
							},
							height = {
								type = 'range',
								name = "Frame Height",
								desc = "Set the total Height of the icon frame.",
								arg = "height",
								get = "Get",
								set = "Set",
								min = 10,
								max = 500,
								step = 0.01,
								order = 2,
								disabled = function() return core.db.profile.modules[name].forcesquare or core.db.profile.modules[name].mode == "icon" end,
							},
							forcesquare = {
								type = 'toggle',
								name = "Force Square Icon",
								desc = "In Frame Mode, forces icon size to square.",
								arg = "forcesquare",
								get = "Get",
								set = "Set",
								order = 3,
							},
						},
					},
				},
			},
			text = {
				type = "group",
				name = LC["%s Text"]:format(module.displayName),
				inline = true,
				order = 5,
				disabled = function() return core.db.profile.modules[name].disableText end,
				args = {
					font = {
						type = 'select',
						name = L["Font"],
						desc = L["Select the font for the text display."],
						arg = "font",
						get = "Get",
						set = "Set",
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						order = 1,
					},
					fontsize = {
						type = 'range',
						name = L["Font Size"],
						desc = L["Set the font size for the text display."],
						arg = "fontsize",
						get = "Get",
						set = "Set",
						min = 1,
						max = 28,
						step = 1,
						order = 2,
					},
					outline = {
						type = 'select',
						name = L["Outline"],
						desc = L["Select the outline style for the text."],
						arg = "outline",
						get = "Get",
						set = "Set",
						values = outlineStyles,
						order = 3,
					},
					textcolor = {
						type = 'color',
						name = L["Text Color"],
						desc = L["Set the color for the text display."],
						arg = "textColor",
						get = "Get",
						set = "Set",
						order = 4,
					},
					textalpha = {
						type = 'range',
						name = L["Text Alpha"],
						desc = L["Set the alpha of the text display."],
						arg = "textAlpha",
						get = "Get",
						set = "Set",
						min = 0.0,
						max = 1.0,
						step = 0.01,
						order = 5,
					},
					textstrata = {
						type = 'select',
						name = L["Text Strata"],
						desc = L["Set the strata level of the text frame."],
						get = "Get",
						set = "Set",
						arg = "textStrata",
						values = stratas,
						order = 6,
					},
					clamp = {
						type = 'toggle',
						name = L["Clamp to Screen"],
						desc = L["Prevent this display from being moved off the screen."],
						get = "Get",
						set = "Set",
						arg = "clampedText",
						order = 7,
					},
					x = {
						type = 'range',
						name = L["X Position"],
						--desc = L[""],
						arg = "textX",
						get = "Get",
						set = "SetPosition",
						softMin = 0,
						softMax = math.floor(GetScreenWidth()),
						step = 1,
						bigStep = 5,
						order = 8,
					},
					y = {
						type = 'range',
						name = L["Y Position"],
						--desc = L[""],
						arg = "textY",
						get = "Get",
						set = "SetPosition",
						softMin = 0,
						softMax = math.floor(GetScreenHeight()),
						step = 1,
						bigStep = 5,
						order = 9,
					},
                    hideTextAtZero = {
						type = 'toggle',
						name = "Hide Text at Zero Points",
						desc = "Do not show the text '0' when you have zero points.",
						arg = "hideTextAtZero",
						get = "Get",
						set = "SetAndUpdate",
						order = 10,
					},
				},
			},
			otherAlerts = {
				type = 'group',
				name = L["Other Alert Styles"],
				inline = true,
				order = 6,
				args = {
					flashHeader = {
						type = 'header',
						name = L["Screen Flash Options"],
						order = 1,
					},
					enableFlash = {
						type = 'toggle',
						name = L["Enable Screen Flash Effect"],
						desc = L["Enables the addon to perform a full-screen flash effect once a certain threshold is reached."],
						get = "Get",
						set = "Set",
						arg = "enableScreenFlash",
						order = 2,
					},
					flashMode = {
						type = 'select',
						name = L["Flash Mode"],
						desc = L["MODE_DESC"],
						get = "Get",
						set = "Set",
						arg = "screenFlashMode",
						values = flashModes,
						disabled = function() return not core.db.profile.modules[name].enableScreenFlash end,
						order = 3,
					},
					flashNumber = {
						type = 'range',
						name = L["Flash Threshold"],
						desc = L["Set the number of points required to show the screen flash effect."],
						get = "Get",
						set = "Set",
						arg = "screenFlashThreshold",
						min = 0,
						max = module.MAX_POINTS,
						step = 1,
						disabled = function() return not core.db.profile.modules[name].enableScreenFlash end,
						order = 4,
					},
					flashColor = {
						type = 'color',
						name = L["Flash Color"],
						desc = L["Select the color for the screen flash effect."],
						get = "Get",
						set = "Set",
						arg = "screenFlashColor",
						disabled = function() return not core.db.profile.modules[name].enableScreenFlash end,
						order = 5,
					},
					flashAlpha = {
						type = 'range',
						name = L["Flash Alpha"],
						desc = L["Set the transparency of the screen flash effect."],
						get = "Get",
						set = "Set",
						min = 0.0,
						max = 1.0,
						step = 0.01,
						arg = "screenFlashAlpha",
						disabled = function() return not core.db.profile.modules[name].enableScreenFlash end,
						order = 6,
					},
				},
			},
			showWhen = {
				type = 'group',
				name = L["Advanced Show/Hide Options"],
				inline = true,
				order = 7,
				args = {
					combat = {
						type = 'toggle',
						name = L["Hide Out of Combat"],
						desc = L["Hide the displays when you are not engaged in combat."],
						get = "Get",
						set = "Set",
						arg = "hideOOC",
						order = 1,
					},
				},
			},
		},
	}
	
	for j = 1, module.MAX_POINTS do
		opts.args[name].args.graphics.args["color"..j] = {
			type = 'color',
			name = format(L["%d |4Point:Points;"], j),
			desc = format(L["Set the color to be used when you have %d |4point:points;."], j),
			arg = j,
			get = "Get",
			set = "Set",
			order = j+1,
		}
	end
	
	i = i + 1
end

if select(2, UnitClass("player")) == "DRUID" then
	opts.args["Combo Points"].args.showWhen.args.catForm = {
		type = 'toggle',
		name = L["Hide Out of Cat Form"],
		desc = L["Hides the displays when you are not in cat form."],
		get = "Get",
		set = "Set",
		arg = "hideOutCat",
		order = 2,
	}
end

--add profile controls
opts.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(core.db)

LibStub('LibDualSpec-1.0'):EnhanceOptions(opts.args.profile, core.db)

LibStub("AceConfig-3.0"):RegisterOptionsTable("ComboPointsRedux", opts)
LibStub("AceConfigDialog-3.0"):SetDefaultSize("ComboPointsRedux", 805, 500)
-- Option menu was acting weird, made it 5 pixels wider.
-- some options were wrapping around to new line without the items below them moving down
-- one pixel wider or thinner would fix it