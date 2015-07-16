package htnPlanner;

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

	var state:State = new State();
	
	public function new() 
	{
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation);
		
	}
	
	public static function main()
	{
		new Main();
	}
}