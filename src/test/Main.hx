package test;

import haxe.Timer;

import htnPlanner.Domain;
import htnPlanner.Problem;
import htnPlanner.Planner;
import htnPlanner.PlannerActionNode;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	//var domainLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/NumRover.pddl";
	//var problemLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/pfile1";
	var domainLocation:String = "pddlexamples/runescape/domain.pddl";
	var problemLocation:String = "pddlexamples/runescape/p1.pddl";
	var domain:Domain;
	var problem:Problem;
	
	public function new()
	{
		
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		
		var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].GetActionTransform());
		}
		
	}
	
	public static function main()
	{
		new Main();
	}
}