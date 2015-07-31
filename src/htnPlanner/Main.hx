package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/domains/classical/settlers/domain.pddl";
	var problemLocation:String = "pddlexamples/domains/classical/settlers/p01_pfile1.pddl";
	var domain:Domain;
	var problem:Problem;

	var state:State = new State();
	
	public function new() 
	{
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		problem.GetClonedInitialState().Print();
		trace(problem.EvaluateMetric(problem.GetClonedInitialState()));
		
		trace(problem.EvaluateGoal(problem.GetClonedInitialState()));
		
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