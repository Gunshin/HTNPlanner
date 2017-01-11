package test.result_generation;

import planner.pddl.Action;
import planner.pddl.Domain;

/**
 * ...
 * @author ...
 */
class ObjectCreationTest
{

	public function new() 
	{
		
	}
	
	public function Run():Bool
	{
		
		var domain:Domain = new Domain("pddlexamples/object_creation/Settlers.pddl");
		
		var action:Action = domain.GetAction("build-cart");
		trace(action.GetData().GetObjectCreationParameters());
		
		return true;
	}
	
}