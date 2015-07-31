package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Requirements
{
	
	static var requirements:Map<String, Bool> = [
		":fluents" => true,
		":typing" => true
	];

	static public function HasRequirement(string_:String):Bool
	{
		if (requirements.exists(string_))
		{
			return true;
		}
		
		throw "This planner does not support the requirement: " + string_;
	}
	
	
}