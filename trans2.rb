require 'rubygems'
require 'rexml/document'
require 'csv'
include REXML

last_fight = REXML::Document.new File.new("lastFight")

puts "导入原始log..."
combat_log = last_fight.elements["*/dict/string/text()"].to_s.split(';')		#导出记录到 "combat_log"
puts "完成"

puts "导入参战卡牌、法球和英雄信息..." 
card_sid = {}
orb_sid = {}
hero_sid = {}

last_fight.elements.each("//dict") { |ele|
	@info = ele.elements
		
	if @info["key/text()"] == "attack"
		card_sid[@info[6].text] = @info[18].text	#记录方式: eles_sid[id] = sid ，这是卡牌
	elsif ele.elements["key/text()"] == "exp"
		orb_sid[@info[4].text] = @info[8].text	#这是法球
	elsif ele.elements["key/text()"] == "card"
		hero_sid[@info[6].text] = @info[18].text	#这是英雄，英雄sid就是名称
	end	
}
puts "完成"

puts "导入所有卡牌名称信息..."
card_name = Hash.new
cards_xml = REXML::Document.new File.new("sample.card.xml")

cards_xml.elements.each("//objects/sample") { |card| 		#导入卡牌
	@att = card.attributes
	card_name[@att["sid"]] = @att["name"]		#卡牌名 name[:sid] = name
}
puts "完成"

puts "导入所有法球名称信息..."
orb_name = Hash.new
orbs_xml = REXML::Document.new File.new("sample.talisman.xml")

orbs_xml.elements.each("//objects/sample") { |orb| 		
	@att = orb.attributes	
	orb_name[@att["sid"]] = @att["name"]		
}
puts "完成"

puts "导入所有技能名称信息..."
skill_name = Hash.new
skills_xml = REXML::Document.new File.new("sample.skills.xml")

skills_xml.elements.each("//objects/sample") { |skill| 
	@att = skill.attributes		
	skill_name[@att["sid"]] = @att["name"]	
}
puts "完成"

puts "导入所有效果名称信息..."
effect_name = Hash.new
effects_xml = REXML::Document.new File.new("sample.effects.xml")
effects_xml.elements.each("//objects/sample") { |effect| 		
	@att = effect.attributes	
	effect_name[@att["sid"]] = @att["bookdes"]		
}
puts "完成"

puts "将原始记录中字符串转译成对应中文..."

combat_log.map! { |log|

	if log.include?(':')
		split_log = Array.new
		split_log = log.split(/:/) 
		
		if split_log[1].include?(',')
			split_value = Array.new
			split_value = split_log[1].split(/,/)
			
			if split_log[0] == "RELEASE_SKILL_SID"
				if orb_sid[split_value[0]].nil?
					log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "释放技能" + ": " + skill_name[split_value[1]] + "(" + split_value[1] + ")"
				else
					log = orb_name[orb_sid[split_value[0]]] + "(" + split_value[0] + ")" + "释放技能" + ": " + skill_name[split_value[1]] + "(" + split_value[1] + ")"
				end
			elsif split_log[0] == "HALO"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "获得光环" + ": " + effect_name[split_value[1]] + "(" + split_value[1] + ")"
			elsif split_log[0] == "BE_CONTROL"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "被控制" + ": 是" + "(" + split_value[1] + ")"			
			elsif split_log[0] == "ARMOR"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "触发减伤" # + ": " + effect_name[split_value[1]] + "(" + split_value[1] + ")"
			elsif split_log[0] == "ADD_LIFE"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "生命上限增加" + ": " + split_value[1]
			elsif split_log[0] == "BLOODTHIRSTINESS"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "攻击吸血" + ": " + split_value[1]
			elsif split_log[0] == "ATTACK_VALUE"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "攻击力变化为" + ": " + split_value[1]
			elsif split_log[0] == "RESTRAINT"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "种族克制增加攻击" + ": " + split_value[1]
			elsif split_log[0] == "BUFF"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "获得效果" + ": " + effect_name[split_value[2]] + "(" + split_value[2] + ")"	
				# "BUFF"中，split_value[1]为type，未使用				
			elsif split_log[0] == "REMOVE_EFFECT"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "移除效果" + ": " + effect_name[split_value[1]] + "(" + split_value[1] + ")" 
			elsif split_log[0] == "PUNCTURE"
				log = hero_sid[split_value[0]] + "(" + split_value[0] + ")" + "被穿刺" + ": " + "(" + split_value[1] + ")" 
				# 这个技能只打英雄
			elsif split_log[0] == "SACRIFICE"
				log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "吞噬" + ": " + card_name[card_sid[split_value[1]]] + "(" + split_value[1] + ")" 
			elsif split_log[0] == "BE_ATTACK_IDS"
				all_target = ""
				split_value.each { |target| all_target += card_name[card_sid[target]] + "(" + target + ")" + " " }
				log = "被攻击: " + all_target  
			elsif split_log[0] == "HUIHUN"
				all_target = ""
				caster = split_value.shift
				split_value.each { |target| all_target += card_name[card_sid[target]] + "(" + target + ")" + " " }
				log = card_name[card_sid[caster]] + "复活: " + all_target + "到牌堆"
			elsif split_log[0] == "BURN"
				all_target = ""
				split_value.each { |target| all_target += card_name[card_sid[target]] + "(" + target + ")" + " " }
				log = "被灼烧" + all_target 
			elsif split_log[0] == "REDUCE_LIFE"
				if card_sid[split_value[0]].nil?
					log = hero_sid[split_value[0]] + "(" + split_value[0] + ")" + "生命减少: " + split_value[1]
				else
					log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "生命减少: " + split_value[1]
				end			
			elsif split_log[0] == "REPLY"
				if card_sid[split_value[0]].nil?
					log = hero_sid[split_value[0]] + "(" + split_value[0] + ")" + "生命恢复: " + split_value[1]
				else
					log = card_name[card_sid[split_value[0]]] + "(" + split_value[0] + ")" + "生命恢复: " + split_value[1]
				end			
			end	
			
		else
			if split_log[0] == "ATTACK"
				if orb_sid[split_log[1]].nil?
					log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "发起攻击"
				else
					log = orb_name[orb_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "发起攻击"
				end
			elsif split_log[0] == "ADD_READY_FIGHTER"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "进入手牌区" 
			elsif split_log[0] == "CAN_ADD_FIGHTER"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "等待完毕" 
			elsif split_log[0] == "ADD_FIGHTER"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "上场"
			elsif split_log[0] == "CLEARDEAD"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + "下场"			
			elsif split_log[0] == "IMMUNITY"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "免疫"
			elsif split_log[0] == "COUNTERATTACK"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "反击"
			elsif split_log[0] == "BLOCK"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "格挡"
			elsif split_log[0] == "DODGE"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "闪避"
			elsif split_log[0] == "CRUE"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "暴击"
			elsif split_log[0] == "REBOUND"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "法术反伤"
			elsif split_log[0] == "BURN"
				log = "被灼烧" + ": " + card_name[card_sid[split_log[1]]] + "(" + split_log[1] + ")"
			elsif split_log[0] == "RETURN"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "回到牌堆"
			elsif split_log[0] == "ZHUNSHENG"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "回到手牌"			
			elsif split_log[0] == "DELIVER"
				log = card_name[card_sid[split_log[1]]] +  "(" + split_log[1] + ")" + ": " + "进入墓地"
			elsif split_log[0] == "SWEEPAWAY"
				log = "被横扫" + ": " + card_name[card_sid[split_log[1]]] + "(" + split_log[1] + ")"
			elsif split_log[0] == "ATTACK_CAMP"	
				log = (split_log[1] == "1") ? "【攻方回合】" : "【守方回合】"
			elsif split_log[0] == "FIGHT_OVER"	
				log = "战斗结束"
			elsif split_log[0] == "BE_ATTACK_IDS"
				if card_sid[split_log[1]].nil?
					log = "被攻击: " + hero_sid[split_log[1]] + "(" + split_log[1] + ")"
				else
					log = "被攻击: " + card_name[card_sid[split_log[1]]] + "(" + split_log[1] + ")"
				end
			end	
		end
		
	elsif log == "CDRUN"	
		log = "【回合结束】"
			
	end

	log
}
puts "完成"

File.open('lastFight.log', 'w') { |file| 
	file.puts "【效果的描述不准确，不要管它！】"
	file.puts combat_log 
}
