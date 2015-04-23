package htnPlanner;

class Effect
{
	public var effect:Array<String>;
	
	public function new(effect_:Array<String>)
	{
		effect = effect_;
	}
}

class PreCondition
{
	public var cost:Float;
	
	public var preConditions:Array<Array<String>>;
	
	public function new(cost_:Float, preConditions_:Array<Array<String>>)
	{
		cost = cost_;
		preConditions = preConditions_;
	}
}

/**
 * ...
 * @author Michael Stephens
 */
class Operand
{
	@:protected
	var name:String;
	
	@:protected
	var preConditions:PreCondition;
	
	@:protected
	var effects:Array<Effect>;

	public function new(name_:String, preConditions_:PreCondition, effects_:Array<Effect>) 
	{
		name = name_;
		preConditions = preConditions_;
		effects = effects_;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetPreConditions():PreCondition
	{
		return preConditions;
	}
	
	public function GetEffects():Array<Effect>
	{
		return effects;
	}
	
}