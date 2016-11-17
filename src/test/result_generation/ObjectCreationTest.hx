package test.result_generation;

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
		
		return true;
	}
	
}