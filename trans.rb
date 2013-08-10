require 'rubygems'
require 'rexml/document'
require 'csv'
include REXML

effects_xml = REXML::Document.new File.new("sample.effects.xml")
skills_xml = REXML::Document.new File.new("sample.skills.xml")
cards_xml = REXML::Document.new File.new("sample.card.xml")
orbs_xml = REXML::Document.new File.new("sample.talisman.xml")
last_fight = REXML::Document.new File.new("lastFight")

card_name = Hash.new

cards_xml.elements.each("//objects/sample") { |card| 		#Import card samples.
	@att = card.attributes		#Get element attribute	
	card_name[@att["sid"]] = @att["name"]		#Get card name as following: card_name[:sid] = name
}

orb_name = Hash.new

orbs_xml.elements.each("//objects/sample") { |orb| 		#Import orb samples.
	@att = orb.attributes		#Get element attribute	
	orb_name[@att["sid"]] = @att["name"]		#Get orb name as following: orb_name[:sid] = name
}

effect_name = Hash.new
effect_type = Hash.new

effects_xml.elements.each("//objects/sample") { |effect| 		#Import effects samples.
	@att = effect.attributes		#Get element attribute
	
	effect_name[@att["sid"]] = @att["bookdes"]		#Get effect name.
	effect_type[@att["sid"]] = @att["type"]		#Get effect type.
}

skill_name = Hash.new
#skill_set_effect = Hash.new

skills_xml.elements.each("//objects/sample") { |skill| 
	@att = skill.attributes
		
	skill_name[@att["sid"]] = @att["name"]
	#skill_set_effect[@att["sid"]] = skill.elements["method/ints/text()"]
}

fight_log = Array.new
fight_log = last_fight.elements["*/dict/string/text()"].to_s.split(';')		#Get combat log

card_sid = Hash.new
orb_sid = Hash.new
hero_sid = Hash.new

last_fight.elements.each("//dict") { |ele|
	@info = ele.elements
		
	if @info["key/text()"] == "attack"
		#puts ("#{@info[6].text} #{@info[18].text}")
		card_sid[@info[6].text] = @info[18].text	#Record card sid as following: card_sid[id] = sid
	elsif ele.elements["key/text()"] == "exp"
		#puts ("#{@info[4].text} #{@info[8].text}")
		orb_sid[@info[4].text] = @info[8].text
	elsif ele.elements["key/text()"] == "card"
		#puts ("#{@info[6].text} #{@info[18].text}")
		hero_sid[@info[6].text] = @info[18].text	
	end
}

round = 1

fight_log.map! { |log|
	split_log = Array.new
	split_skill = Array.new
	split_target = Array.new
		
	if log.include?(':')
		split_log = log.split(/:/) 
		
		#(card_sid[split_log[1]].nil?) ? orb_sid[split_log[1]] : card_sid[split_log[1]]
		
		if split_log[0] == "ATTACK"
			log = "发起攻击" + " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " unless card_sid[split_log[1]].nil?
			log = "法球攻击" + " : " + orb_name[orb_sid[split_log[1]]] + " (" + split_log[1] + ") " unless orb_sid[split_log[1]].nil?
		elsif split_log[0] == "ADD_READY_FIGHTER"
			log = "进入手牌区" + " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " #unless card_sid[split_log[1]].nil?
			#log = "满足触发条件" + " : " + orb_name[orb_sid[split_log[1]]] + " (" + split_log[1] + ") " unless orb_sid[split_log[1]].nil?
		elsif split_log[0] == "CAN_ADD_FIGHTER"
			log = "完成等待" + " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " 
		elsif split_log[0] == "ADD_FIGHTER"
			log = "上场" + " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " #unless card_sid[split_log[1]].nil?
			#log = "发动" + " : " + orb_name[orb_sid[split_log[1]]] + " (" + split_log[1] + ") " unless orb_sid[split_log[1]].nil?
		elsif split_log[0] == "CLEARDEAD"
			log = "下场" + " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " unless card_sid[split_log[1]].nil?
			log = "失效" + " : " + orb_name[orb_sid[split_log[1]]] + " (" + split_log[1] + ") " unless orb_sid[split_log[1]].nil?
		elsif split_log[0] == "IMMUNITY"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "免疫"
		elsif split_log[0] == "COUNTERATTACK"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "反击"
		elsif split_log[0] == "BLOCK"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "格挡"
		elsif split_log[0] == "DODGE"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "闪避"
		elsif split_log[0] == "CRUE"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "暴击"
		elsif split_log[0] == "REBOUND"
			log = card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " + " : " + "反弹法术伤害"			
		elsif split_log[0] == "RELEASE_SKILL_SID"
			split_skill = split_log[1].split(/,/)			
			log = card_name[card_sid[split_skill[0]]] + "释放技能" + " : " + skill_name[split_skill[1]] + " (" + split_skill[1] + ") " unless card_sid[split_skill[0]].nil?
			log = orb_name[orb_sid[split_skill[0]]] + "释放技能" + " : " + skill_name[split_skill[1]] + " (" + split_skill[1] + ") " unless orb_sid[split_skill[0]].nil?
		elsif split_log[0] == "HALO"
			split_skill = split_log[1].split(/,/)			
			log = card_name[card_sid[split_skill[0]]] + "获得光环" + " : " + skill_name[split_skill[1]] + " (" + split_skill[1] + ") "			
		elsif split_log[0] == "BE_CONTROL"
			split_skill = split_log[1].split(/,/)			
			log = card_name[card_sid[split_skill[0]]] + "被控制" + " : " + "是" + " (" + split_skill[1] + ") "			
		elsif split_log[0] == "ARMOR"
			split_skill = split_log[1].split(/,/)			
			log = card_name[card_sid[split_skill[0]]] + "触发减伤" + " : " + effect_name[split_skill[1]] + " (" + split_skill[1] + ") "			
		elsif split_log[0] == "BE_ATTACK_IDS"
			if split_log[1].include?(',')
				split_target = split_log[1].split(/,/)
				all_target = ""
				split_target.each { |target| all_target += card_name[card_sid[target]] + " (" + target + ")"+ " "}
				log = "被攻击" " : " + all_target
			else
				log = "被攻击" " : " + card_name[card_sid[split_log[1]]] + " (" + split_log[1] + ") " unless card_sid[split_log[1]].nil?
				log = "被攻击" " : " + hero_sid[split_log[1]] + " (" + split_log[1] + ") " unless hero_sid[split_log[1]].nil?
			end
		elsif split_log[0] == "REDUCE_LIFE"
			split_skill = split_log[1].split(/,/)
			log = card_name[card_sid[split_skill[0]]] + " (" + split_skill[0] + ") " + "生命减少" + " : " + split_skill[1] unless card_sid[split_skill[0]].nil?
			log = hero_sid[split_skill[0]] + " (" + split_skill[0] + ") " + "生命减少" + " : " + split_skill[1] unless hero_sid[split_skill[0]].nil?
		elsif split_log[0] == "ADD_LIFE"
			split_skill = split_log[1].split(/,/)
			log = card_name[card_sid[split_skill[0]]] + " (" + split_skill[0] + ") " + "生命上限增加" + " : " + split_skill[1]
		elsif split_log[0] == "ATTACK_VALUE"
			split_skill = split_log[1].split(/,/)
			log = card_name[card_sid[split_skill[0]]] + " (" + split_skill[0] + ") " + "攻击力变化为" + " : " + split_skill[1]
		elsif split_log[0] == "BUFF"
			split_skill = split_log[1].split(/,/)
			log = card_name[card_sid[split_skill[0]]] + "获得效果" + " : " + effect_name[split_skill[2]] + " (" + split_skill[2] + ") " #Gain effect: card + #type + effect name
			#log = card_name[card_sid[split_skill[0]]] + "获得效果" + " : " + "类型" + effect_type[split_skill[1]] + " (" + split_skill[1] + ") " + effect_name[split_skill[2]] + " (" + split_skill[2] + ") " #获得效果 ：卡牌 + 类型 + 描述
		elsif split_log[0] == "REMOVE_EFFECT"
			split_skill = split_log[1].split(/,/)
			log = card_name[card_sid[split_skill[0]]] + "移除效果" + " : " + effect_name[split_skill[1]] + " (" + split_skill[1] + ") " #Remove effect: card + effect name
		elsif split_log[0] == "ATTACK_CAMP"	
			log = (split_log[1] == "1") ? "攻方回合" : "守方回合"
		elsif split_log[0] == "FIGHT_OVER"	
			log = "战斗结束"
		end
	elsif log == "CDRUN"	
		log = "回合" + round.to_s + "结束"
		round += 1	
	end

	log
}

File.open('lastFight.log', 'w') { |file| file.puts fight_log }

	
	
	
	
	
	