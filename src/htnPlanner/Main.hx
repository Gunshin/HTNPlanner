package htnPlanner;

import haxe.Timer;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/Strips/driverlog.pddl";
	var problemLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/Strips/pfile1";
	var domain:Domain;
	var problem:Problem;

	var state:State = new State();
	
	public function new() 
	{
		
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		
		var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		for (i in array)
		{
			trace(i.action.GetName() + " _ " + i.params.toString());
		}
		
		/*var action = domain.GetAction("drive");
		
		var initState = problem.GetClonedInitialState();
		
		action.SetParameter("?t", "truck1", "truck", domain);
		
		action.SetParameter("?from", "l3", "location", domain);
		action.SetParameter("?to", "l1", "location", domain);
		
		action.SetParameter("?t1", "t0", "time", domain);
		action.SetParameter("?t2", "t1", "time", domain);
		
		trace(action.Evaluate(initState, domain));
		initState.Print();
		var newState:State = action.Execute(initState, domain);
		newState.Print();
		
		trace(initState.GenerateStateHash());
		trace(newState.GenerateStateHash());*/
	}
	
	public static function main()
	{
		new Main();
	}
}