require 'rexml/document'
include REXML

cards_xml = REXML::Document.new File.new("sample.card.xml")
card = []		#建立卡牌数组来索引
card_name = Hash.new 	#卡牌名字典表

class Card 		#建立卡牌类
	attr_accessor :sid, :type, :cname, :spit_exp, :star, :cost, :cd, :sale_money
	attr_accessor :set_skills
	
	def initialize(sid)
		@sid = sid
	end
	
	def assign(name, value)
		if name == "type"
			if value == '1'
				@type = '人族'
			elsif value == '2'
				@type = '精灵'
			elsif value == '3'
				@type = '兽族'
			elsif value == '4'
				@type = '亡灵'
			elsif value == '0'
				@type = 'Boss'
			else
				@type = value
			end
		elsif name == "name"
			@cname = value 
		elsif name == "spitExp"
			@spit_exp = value
		elsif name == "star"
			@star = value 
		elsif name == "cost"
			@cost = value 
		elsif name == "cd"
			@cd = value 
		elsif name == "saleMoney"
			@sale_money = value
		end
	end

end

sid = 0
puts "读取卡牌数据..."

cards_xml.elements.each("//objects/sample") { |current_card|	#读卡牌数据
	current_card.attributes.each	{ |attr|
		if attr.first == "sid"
			sid = attr.last.to_i
			card[attr.last.to_i] = Card.new(attr.last) 
		else
			#puts ("#{attr.first} and #{attr.last}, #{sid}")
			card[sid].assign(attr.first, attr.last) if sid != 0 
		end
	}
	#puts ("#{current_card.elements["method/name"].text}, with the #{sid}")
	card_name[sid] = card[sid].cname
	card[sid].set_skills = current_card.elements["method/ints"].text.split(/,/)
	#puts card[sid].set_skills
}

orbs_xml = REXML::Document.new File.new("sample.talisman.xml")
orb = []
orb_name = Hash.new

class Orb
	attr_accessor :sid, :type, :oname, :books, :spit_exp, :star, :sale_money
	attr_accessor :trigger_type, :trigger_condition_type, :trigger_race, :calculate_type, :trigger_count, :limit_num
	attr_accessor :skill_sid
	
	def initialize(sid)
		@sid = sid
	end
	
	def assign(name, value)
		if name == "type"
			if value == '1'
				@type = "风"
			elsif value == '2'
				@type = "火"
			elsif value == '3'
				@type = "土"
			elsif value == '4'
				@type = "水"
			elsif value == '5'
				@type = "垃圾"
			elsif value == '6'
				@type = "碎片"
			end
		elsif name == "name"
			@oname = value 
		elsif name == "books"
			@books = value
		elsif name == "spitExp"
			@spit_exp = value
		elsif name == "star"
			@star = value 
		elsif name == "saleMoney"
			@sale_money = value
		elsif name == "triggerType"
			if value == '0'
				@trigger_type = "我"
			elsif value == '1'
				@trigger_type = "敌"
			else
				@trigger_type = value
			end
		elsif name == "triggerConditionType"
			if value == '1'
				@trigger_condition_type = "场上"
			elsif value == '2'
				@trigger_condition_type = "手牌"
			elsif value == '3'
				@trigger_condition_type = "墓地"
			elsif value == '5'
				@trigger_condition_type = "英雄"
			elsif value == '6'
				@trigger_condition_type = "回合"
			elsif value == '7'
				@trigger_condition_type = "牌堆"
			else	
				@trigger_condition_type = value
			end
		elsif name == "triggerRace"
			if value == '1'
				@trigger_race = "人类"
			elsif value == '2'
				@trigger_race = "精灵"
			elsif value == '3'
				@trigger_race = "兽人"
			elsif value == '4'
				@trigger_race = "亡灵"
			else	
				@trigger_race = value
			end
		elsif name == "calculateType"
			if value == '0'
				@calculate_type = "大于"
			elsif value == '1'
				@calculate_type = "小于"
			else
				@calculate_type = value
			end
		elsif name == "triggerCount"
			@trigger_count = value
		elsif name == "limitNum"
			@limit_num = value
		end
	end
	
end

sid = 0
puts "读取法球数据..."

orbs_xml.elements.each("//objects/sample") { |current_orb|	
	current_orb.attributes.each	{ |attr|
		if attr.first == "sid"
			sid = attr.last.to_i
			orb[attr.last.to_i] = Orb.new(attr.last) 
		else
			#puts ("#{attr.first} and #{attr.last}, #{sid}")
			orb[sid].assign(attr.first, attr.last) if sid != 0 
		end
	}
	#puts ("#{current_card.elements["field/ints"].text}, with the #{sid}")
	orb_name[sid] = orb[sid].oname
	orb[sid].skill_sid = current_orb.elements["field/ints"].text.split(/,/) unless current_orb.elements["field/ints"].nil?
	#puts orb[sid].skill_sid unless orb[sid].skill_sid.nil?
}

skills_xml = REXML::Document.new File.new("sample.skills.xml")
skill = []
skill_name = Hash.new

class Skill 
	attr_accessor :sid, :sname, :bookdes, :priority_level, :skill_type, :is_positive, :attack_type, :attack_sub_type
	attr_accessor :targer, :range, :attack_count, :value, :max_value, :is_hurt
	attr_accessor :set_effects
	
	def initialize(sid)
		@sid = sid
	end
	
	def assign(name, value)
		if name == "name"
			@sname = value
		elsif name == "bookdes"
			@bookdes = value 
		elsif name == "priorityLevel"
			@priority_level = value
		elsif name == "skillType"
			@skill_type = value 
		elsif name == "isPositive"
			@is_positive = value 
		elsif name == "attackType"
			@attack_type = value 
		elsif name == "attackSubType"
			if value == '1'
				@attack_sub_type = '雷'
			elsif value == '2'
				@attack_sub_type = '火'
			elsif value == '8'
				@attack_sub_type = '水'
			elsif value == '16'
				@attack_sub_type = '普通攻击'
			elsif value == '32'
				@attack_sub_type = '毒'
			elsif value == '64'
				@attack_sub_type = '法球增益'
			elsif value == '1024'
				@attack_sub_type = '治疗'
			else				
				@attack_sub_type = value
			end
		elsif name == "targer"
			if value == '0'
				@targer = '我'
			elsif value == '1'
				@targer = '敌'
			else
				@targer = value
			end
		elsif name == "range"
			@range = value
		elsif name == "attackCount"
			@attack_count = value
		elsif name == "value"
			@value = value
		elsif name == "maxValue"
			@max_value = value
		elsif name == "isHurt"
			@is_hurt = value
		end
	end
	
end

sid = 0
puts "读取技能数据..."

skills_xml.elements.each("//objects/sample") { |current_skill|
	current_skill.attributes.each	{ |attr|
		if attr.first == "sid"
			sid = attr.last.to_i
			skill[attr.last.to_i] = Skill.new(attr.last) 
		else
			#puts ("#{attr.first} : #{attr.last} : #{sid}")
			skill[sid].assign(attr.first, attr.last) 
		end
	}
	#puts ("#{current_skill.elements["method/ints"].text}, with the #{sid}")
	skill_name[sid] = skill[sid].sname
	
	if current_skill.elements["method/ints"].nil?
		skill[sid].set_effects = 0
	else
		skill[sid].set_effects = current_skill.elements["method/ints"].text.split(/,/)
	end
	#puts skill[sid].sname

}

effects_xml = REXML::Document.new File.new("sample.effects.xml")
effect = []
effect_detail = Hash.new
		
class Effect 
	attr_accessor :sid, :bookdes, :type, :sub_type, :value1, :value2, :value3, :relationship, :rounds_count
	attr_accessor :calculate_type, :targer, :range
	
	def initialize(sid)
		@sid = sid
	end
	
	def assign(name, value)
		if name == "bookdes"
			@bookdes = value 
		elsif name == "type"
			@type = value
		elsif name == "subType"
			@sub_type = value 
		elsif name == "value1"
			@value1 = value 
		elsif name == "value2"
			@value2 = value 
		elsif name == "value3"
			@value3 = value
		elsif name == "relationship"
			@relationship = value
		elsif name == "roundsCount"
			if value == '999'
				@rounds_count = "始终"
			else	
				@rounds_count = value
			end
		elsif name == "calculateType"
			@calculate_type = value
		elsif name == "targer"
			@targer = value
		elsif name == "range"
			@range = value
		end
	end

end

sid = 0
puts "读取效果数据..."

effects_xml.elements.each("//objects/sample") { |current_effect|
	current_effect.attributes.each	{ |attr|
		if attr.first == "sid"
			sid = attr.last.to_i
			effect[attr.last.to_i] = Effect.new(attr.last) 
		else
			effect[sid].assign(attr.first, attr.last) if sid != 0
		end
	}
	#puts ("#{current_effect.elements["method/ints"].text}, with the #{sid}")
	effect_detail[sid] = effect[sid].bookdes
}

rewards_xml = REXML::Document.new File.new("sample.prize.xml")
reward = []

class Reward
	attr_accessor :sid, :currency, :gold, :money, :min_money, :max_money, :exp, :min_exp, :max_exp, :dynamic
	attr_accessor :randomc, :randomt, :hide_sid, :maze_sid
	attr_accessor :card_sids, :orb_sid
	
	def initialize(sid)
		@sid = sid
	end
	
	def assign(name, value)
		if name == "currency"
			@currency = value 
		elsif name == "gold"
			@gold = value
		elsif name == "money"
			@money = value 
		elsif name == "minMoney"
			@min_money = value 
		elsif name == "maxMoney"
			@max_money = value 
		elsif name == "exp"
			@exp = value
		elsif name == "minExp"
			@min_exp = value
		elsif name == "maxExp"
			@max_exp = value
		elsif name == "dymnamic"
			@dynamic = value
		elsif name == "randomc"
			@randomc = value
		elsif name == "randomt"
			@randomt = value
		elsif name == "hideSid"
			@hide_sid = value
		elsif name == "mazeSid"
			@maze_sid = value
		end
	end
end

sid = 0
puts "读取奖励数据..."

rewards_xml.elements.each("//objects/sample") { |current_reward|
	current_reward.attributes.each	{ |attr|
		if attr.first == "sid"
			sid = attr.last.to_i
			reward[attr.last.to_i] = Reward.new(attr.last) 
		else
			reward[sid].assign(attr.first, attr.last) if sid != 0
		end
	}

	#puts ("#{current_reward.elements["field"].attributes["name"]}, with the #{sid}") unless current_reward.elements["field"].nil?

	if current_reward.elements["field"] != nil
		if current_reward.elements["field"].attributes["name"] == "talismans"
			reward[sid].orb_sid = current_reward.elements["field/ints"].text.split(/,/)
		elsif current_reward.elements["field"].attributes["name"] == "cardSids"
			reward[sid].card_sids = current_reward.elements["field/ints"].text.split(/,/)
		end
	end
	
}

require 'spreadsheet'
xls = Spreadsheet::Workbook.new

	puts "汇入卡牌数据..."
	card_sheet = xls.create_worksheet
	card_sheet.name = '卡牌'
	card_sheet.row(0).push "sid", "名称", "种族", "产生经验", "星数", "cost", "冷却", "出售价格" 
	card_sheet.row(0).push "技能1", "技能2", "技能3", "技能4"
	card_sheet.column(8).width = 20
	card_sheet.column(9).width = 20
	card_sheet.column(10).width = 20
	card_sheet.column(11).width = 20
	start_row = 1

	card.each { |card|		
		if card.nil?
		else
			card_sheet.row(start_row).push card.sid.to_i, card.cname, card.type, card.spit_exp.to_i, card.star.to_i, card.cost.to_i, card.cd.to_i, card.sale_money.to_i		#写数据
			card.set_skills.each { |set_skill| card_sheet.row(start_row).push skill_name[set_skill.to_i] } 
		start_row += 1
		end
	}

	puts "汇入法球数据..."
	orb_sheet = xls.create_worksheet
	orb_sheet.name = '法球'
	orb_sheet.row(0).push "sid", "类型", "名称", "说明", "产生经验", "星数", "售价" 
	orb_sheet.row(0).push "敌我触发", "触发条件", "触发种族", "计算类型", "触发数字", "发动次数"
	orb_sheet.row(0).push "一级法术", "二级法术", "三级法术", "四级法术", "五级法术"
	orb_sheet.column(3).width = 45
	orb_sheet.column(13).width = 20
	orb_sheet.column(14).width = 20
	orb_sheet.column(15).width = 20
	orb_sheet.column(16).width = 20
	orb_sheet.column(17).width = 20
	start_row = 1

	orb.each { |orb|		
		if orb.nil?
		else
			orb_sheet.row(start_row).push orb.sid, orb.type, orb.oname, orb.books, orb.spit_exp.to_i, orb.star.to_i, orb.sale_money.to_i
			orb_sheet.row(start_row).push orb.trigger_type, orb.trigger_condition_type, orb.trigger_race, orb.calculate_type, orb.trigger_count.to_i, orb.limit_num.to_i
			orb.skill_sid.each { |skill_sid| orb_sheet.row(start_row).push skill_name[skill_sid.to_i]} unless orb.skill_sid.nil? 
		start_row += 1
		end
	}

	puts "汇入技能数据..."
	skill_sheet = xls.create_worksheet
	skill_sheet.name = '技能'
	skill_sheet.row(0).push "sid", "名称", "描述", "优先级", "类型", "子类型" 
	skill_sheet.row(0).push "敌我", "范围", "数量", "最小伤害", "最大伤害", "有效性"
	skill_sheet.row(0).push "效果1", "效果2", "效果3"
	skill_sheet.column(2).width = 40
	skill_sheet.column(12).width = 40
	skill_sheet.column(13).width = 40
	skill_sheet.column(14).width = 40
	start_row = 1

	skill.each { |skill|		
		if skill.nil?
		else
			skill_sheet.row(start_row).push skill.sid.to_i, skill.sname, skill.bookdes, skill.priority_level, skill.attack_type, skill.attack_sub_type
			skill_sheet.row(start_row).push skill.targer, skill.range, skill.attack_count, skill.value.to_i, skill.max_value.to_i, skill.is_hurt
			if skill.set_effects.kind_of?(Array)
				skill.set_effects.each { |effect| skill_sheet.row(start_row).push effect_detail[effect.to_i] }
			else
				skill_sheet.row(start_row).push effect_detail[skill.set_effects.to_i]
			end
			start_row += 1
		end
	}

	puts "汇入效果数据..."
	effect_sheet = xls.create_worksheet
	effect_sheet.name = '效果'
	effect_sheet.row(0).push "sid", "描述", "类型", "子类型", "值1", "值2", "值3", "关系", "持续回合"
	effect_sheet.row(0).push "计算类型", "目标", "范围"
	effect_sheet.column(1).width = 45
	start_row = 1

	effect.each { |effect|		
		if effect.nil?
		else
			effect_sheet.row(start_row).push effect.sid, effect.bookdes, effect.type, effect.sub_type, effect.value1, effect.value2, effect.value3, effect.relationship, effect.rounds_count
			effect_sheet.row(start_row).push effect.calculate_type, effect.targer, effect.range
			start_row += 1
		end
	}	
	
	puts "汇入奖励数据..."
	reward_sheet = xls.create_worksheet
	reward_sheet.name = '奖励'
	reward_sheet.row(0).push "sid", "召唤卡", "紫晶", "金币", "最小金币", "最大金币", "经验", "最小经验", "最大经验", "体力"
	reward_sheet.row(0).push "卡牌概率", "法球概率", "开启隐藏关", "开启迷宫"
	reward_sheet.row(0).push "奖励卡牌或法球"
	effect_sheet.column(14).width = 150
	start_row = 1

	reward.each { |reward|		
		if reward.nil?
		else
			reward_sheet.row(start_row).push reward.sid, reward.currency, reward.gold, reward.money, reward.min_money, reward.max_money, reward.exp, reward.min_exp, reward.max_exp, reward.dynamic
			reward_sheet.row(start_row).push reward.randomc, reward.randomt, reward.hide_sid, reward.maze_sid
		
			if reward.card_sids != nil
				reward.card_sids.map! { |card_sid|
					card_sid = card_name[card_sid.to_i] if card_sid.to_i > 999
					card_sid
				}
				#puts reward.card_sids.join(',')
				reward_sheet.row(start_row).push reward.card_sids.join(',')
			elsif reward.orb_sid != nil
				reward_sheet.row(start_row).push reward.orb_sid.first + ',' + orb_name[reward.orb_sid.last.to_i]
			end

			start_row += 1
		end
	}
	
	
	
puts "写入文件..."
xls.write 'Config.xls'
