package test;

import haxe.Timer;
import planner.pddl.Action;
import planner.pddl.State;

import planner.pddl.Domain;
import planner.pddl.Problem;
import planner.pddl.Planner;
import planner.pddl.PlannerActionNode;

import planner.pddl.Utilities;
import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;
import planner.pddl.tree.TreeNodeFunction;
import planner.pddl.tree.TreeNodeInt;
import planner.pddl.tree.TreeNodeValue;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:Array<String> = [
	"pddlexamples/IPC3/Tests2/Rovers/Numeric/NumRover.pddl",
	"pddlexamples/runescape/domain.pddl",
	"pddlexamples/IPC3/Tests3/Settlers/Numeric/Settlers.pddl",
	"pddlexamples/IPC3/Tests1/DriverLog/Strips/driverlog.pddl",
	"pddlexamples/test/domain.pddl",
	"pddlexamples/benchmarksV1.1/TESTING/seq-agl/Barman/domain.pddl",
	"pddlexamples/runescape/quest_sequence.pddl"
	];
	var problemLocation:Array<String> = [
	"pddlexamples/IPC3/Tests2/Rovers/Numeric/pfile1",
	"pddlexamples/runescape/p1.pddl",
	"pddlexamples/IPC3/Tests3/Settlers/Numeric/pfile1",
	"pddlexamples/IPC3/Tests1/DriverLog/Strips/pfile3",
	"pddlexamples/test/p1.pddl",
	"pddlexamples/benchmarksV1.1/TESTING/seq-agl/Barman/p4-11-4-15.pddl",
	"pddlexamples/runescape/quest_sequence_p1.pddl"
	];
	
	public function new()
	{
		//UnitTests();
		
		
		var domainIndex:Int = 6;
		
		var domain = new Domain(domainLocation[domainIndex]);
		var problem = new Problem(problemLocation[domainIndex], domain);
		//trace(problem.GetClonedInitialState());
		
		/*var state:State = problem.GetClonedInitialState();

		var action_g:Action = domain.GetAction("get_minimum_xp");
		action_g.GetData().SetParameter("?quest", "dorics_quest");
		action_g.GetData().SetParameter("?skill", "mining");
		
		trace(action_g.Evaluate(state, domain));
		trace(state = action_g.Execute(state, domain));
		
		trace(state.GetFunction("skill_level mining"));
		
		var action_c:Action = domain.GetAction("complete_quest");
		action_c.GetData().SetParameter("?quest", "dorics_quest");
		
		for ( child in action_c.GetPreconditionTree().GetBaseNode().GetChildren())
		{
			trace(child.Evaluate(action_c.GetData(), state, domain) + "\n" + child + "\n\n");
		}*/
		
		//trace(action.Evaluate(state, domain));
		//trace(action.Execute(state, domain));
		
		
		var start:Float = Sys.cpuTime();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem, true);
		
		trace((Sys.cpuTime() - start));
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].GetActionTransform());
		}
		
	}
	
	public function UnitTests()
	{
		var domain:Domain = new Domain("src/test/runescape/domain.pddl");
		var problem = new Problem("src/test/runescape/p1.pddl", domain);
		
		trace("Starting Action Tests");
		var action:Action = domain.GetAction("Cut_Down_Tree");
		
		Assert((action != null), "Could not find action");
		Assert((action.GetData().GetParameter("?resource") != null), "Could not find parameter");
		Assert((action.GetData().GetValue("~count") != null), "Could not find value");
		
		trace("Starting Plan Test");		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem, true);
		
		Assert((array.length == 2), "Plan length is wrong");
		var compareArray:Array<String> = [
			"Move_To bank_area logs_area",
			"Cut_Down_Tree logs logs_area 15"
		];
		
		for (i in 0...array.length)
		{
			Assert((Utilities.Compare(array[i].GetActionTransform(), compareArray[i]) == 0), "Task: " + i + " is wrong");
		}
	}
	
	inline function Assert(flag_:Bool, mes_:String)
	{
		if (!flag_)
		{
			trace( "ERROR: " + mes_);
			throw "";
		}
	}
	
	public static function main()
	{
		new Main();
	}
}