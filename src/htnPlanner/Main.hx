package htnPlanner;

import htnPlanner.Operand.Effect;
import htnPlanner.Operand.PreCondition;

import htnPlanner.TaskManager;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/domain.pddl";
	var problemLocation:String = "pddlexamples/p01.pddl";
	var domain:Domain;
	var problem:Problem;

	var taskManager:TaskManager = new TaskManager();
	var state:State = new State();
	
	public function new() 
	{
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation);
		
		var p = domain.predicates.get("at");
		p.GetParameter("?x").SetValue("truck1", "truck", domain);
		p.GetParameter("?l").SetValue("l3", "location", domain);
		
		trace(p.Construct());
	}
	
	public static function main()
	{
		new Main();
	}
}