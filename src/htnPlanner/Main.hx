package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/Driverlog_pddl/driverlog.pddl";
	var problemLocation:String = "pddlexamples/Driverlog_pddl/pfile01.pddl";
	var domain:Domain;
	var problem:Problem;

	var state:State = new State();
	
	public function new() 
	{
		
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
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