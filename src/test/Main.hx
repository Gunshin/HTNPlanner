package test;

import planner.pddl.Pair;
import sys.io.File;
import sys.io.FileOutput;

import haxe.Timer;
import planner.pddl.Action;
import planner.pddl.State;

import planner.pddl.Domain;
import planner.pddl.Problem;
import planner.pddl.Planner;
import planner.pddl.planner.PlannerActionNode;

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
	"pddlexamples/IPC3/Tests2/Rovers/Numeric/NumRover.pddl", // length 10
	"pddlexamples/runescape/domain2.pddl",
	"pddlexamples/IPC3/Tests3/Settlers/Numeric/Settlers.pddl",
	"pddlexamples/IPC3/Tests1/DriverLog/Strips/driverlog.pddl",
	"pddlexamples/test/domain.pddl",
	"pddlexamples/benchmarksV1.1/TESTING/seq-agl/Barman/domain.pddl",
	"pddlexamples/runescape/quest_sequence.pddl",
	"pddlexamples/test/Settlers.pddl"
	];
	var problemLocation:Array<String> = [
	"pddlexamples/IPC3/Tests2/Rovers/Numeric/pfile1",
	"pddlexamples/runescape/p2.pddl",
	"pddlexamples/IPC3/Tests3/Settlers/Numeric/pfile1",
	"pddlexamples/IPC3/Tests1/DriverLog/Strips/pfile3",
	"pddlexamples/test/p1.pddl",
	"pddlexamples/benchmarksV1.1/TESTING/seq-agl/Barman/p4-11-4-15.pddl",
	"pddlexamples/runescape/quest_sequence_p1.pddl",
	"pddlexamples/test/pfile1"
	];
	
	
	
	public function new()
	{
		//UnitTests();
		Utilities.WriteToFile("output.txt", "", false);
		
		var domainIndex:Int = 7;
		
		var domain:Domain = new Domain("pddlexamples/Results/IntegerParameters/SettlersIntegerParameters.pddl");
		
		trace(domain.GetAllFunctionsWithinActionPrecondition("make-iron"));
		
		/*for (i in domain.GetActionsWithFunctionEffect("available"))
		{
			trace(i.GetName());
		}*/
		
		//GetResults("results.txt", ["pddlexamples/Results/IntegerParameters/SettlersIntegerParameters.pddl"], ["pddlexamples/Results/IntegerParameters/Test1/pfile20"], 1);
		//GetResults("results2.txt", ["pddlexamples/Results/IntegerParameters/Settlers.pddl"], ["pddlexamples/Results/IntegerParameters/Test2/pfile2"], 1);
		
		
		//GetResults("results2.txt", ["pddlexamples/test/small_settlers/Settlers.pddl"], ["pddlexamples/test/small_settlers/pfile0"]);
		//GetResults("results2.txt", ["pddlexamples/test/small_settlers/SettlersIntegerParameters.pddl"], ["pddlexamples/test/small_settlers/pfile0"]);
		
		
		/*GetResults("pddlexamples/Results/IntegerParameters/Test1/results.txt", 
		[
			"pddlexamples/Results/IntegerParameters/Settlers.pddl",
			"pddlexamples/Results/IntegerParameters/SettlersIntegerParameters.pddl"
		],
		[
			"pddlexamples/Results/IntegerParameters/Test1/pfile0",
			"pddlexamples/Results/IntegerParameters/Test1/pfile1",
			"pddlexamples/Results/IntegerParameters/Test1/pfile2",
			"pddlexamples/Results/IntegerParameters/Test1/pfile3",
			"pddlexamples/Results/IntegerParameters/Test1/pfile4",
			"pddlexamples/Results/IntegerParameters/Test1/pfile5",
			"pddlexamples/Results/IntegerParameters/Test1/pfile6",
			"pddlexamples/Results/IntegerParameters/Test1/pfile7",
			"pddlexamples/Results/IntegerParameters/Test1/pfile8",
			"pddlexamples/Results/IntegerParameters/Test1/pfile9",
			"pddlexamples/Results/IntegerParameters/Test1/pfile10"
		], 100);*/
		
		/*GetResults("pddlexamples/Results/IntegerParameters/Test2/results.txt", 
		[
			"pddlexamples/Results/IntegerParameters/Settlers.pddl",
			"pddlexamples/Results/IntegerParameters/SettlersIntegerParameters.pddl"
		],
		[
			"pddlexamples/Results/IntegerParameters/Test2/pfile0",
			"pddlexamples/Results/IntegerParameters/Test2/pfile2",
			"pddlexamples/Results/IntegerParameters/Test2/pfile4",
			"pddlexamples/Results/IntegerParameters/Test2/pfile6",
			"pddlexamples/Results/IntegerParameters/Test2/pfile8",
			"pddlexamples/Results/IntegerParameters/Test2/pfile10"
		]);*/
		
		/*var start:State = problem.GetClonedInitialState();
		start.SetFunction("available timber location0", 10);
		//start.AddRelation("has-sawmill location0");
		
		var saw:Action = domain.GetAction("saw-wood");
		
		saw.GetData().SetParameter("?p", "location0");
		saw.GetData().SetValue("~count", "7");
		
		trace(saw.Evaluate(start, domain));

		for (child in saw.GetPreconditionTree().GetBaseNode().GetChildren())
		{
			trace(child.GetRawTreeString() + " ___: " + child.Evaluate(saw.GetData(), start, domain));
		}*/
		
		
	}
	
	public function GetResults(output_file_:String, domains_:Array<String>, problems_:Array<String>, iterations_:Int)
	{
		Utilities.WriteToFile(output_file_, "", false);
		
		var averages_times:Array<Array<Float>> = new Array<Array<Float>>();
		
		for (dom_index in 0...domains_.length)
		{
			averages_times.push(new Array<Float>());
			for (prob_index in 0...problems_.length)
			{
				averages_times[dom_index][prob_index] = 0;
			}
		}
		
		for (iteration in 0...iterations_)
		{
			trace("Iteration: " + iteration);
			for (domain_index in 0...domains_.length)
			{
				var domain_path:String = domains_[domain_index];
				for (problem_index in 0...problems_.length)
				{
					var problem_path:String = problems_[problem_index];
					
					var domain:Domain = new Domain(domain_path);
					var problem:Problem = new Problem(problem_path, domain);
					
					Utilities.WriteToFile(output_file_, "Domain: " + domain_path + " Problem: " + problem_path + "\n", true);
					
					var start:Float = Sys.cpuTime();
					
					var planner:Planner = new Planner();
					var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem, true);
					
					averages_times[domain_index][problem_index] += Sys.cpuTime() - start;
					
					Utilities.WriteToFile(output_file_, "Time taken seconds: " + (Sys.cpuTime() - start) + "\n", true);
					Utilities.WriteToFile(output_file_, "Plan length: " + array.length + "\n", true);
					Utilities.WriteToFile(output_file_, "Closed list length: " + planner.GetClosedListLength() + " Open list length: " + planner.GetOpenListLength() + "\n", true);
					
					for (i in 0...array.length)
					{
						Utilities.WriteToFile(output_file_, array[i].GetActionTransform() + "\n", true);
					}
					
					Utilities.WriteToFile(output_file_, "\n\n\n", true);
				}
			}
		}
		
		for (domain_index in 0...averages_times.length)
		{
			var domain_path:String = domains_[domain_index];
			for (problem_index in 0...averages_times[domain_index].length)
			{
				var problem_path:String = problems_[problem_index];
				
				averages_times[domain_index][problem_index] /= iterations_;
				
				Utilities.WriteToFile(output_file_, "Domain: " + domain_path + " Problem: " + problem_path + "\n", true);
				Utilities.WriteToFile(output_file_, "Time taken seconds: " + averages_times[domain_index][problem_index] + "\n", true);
			}
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