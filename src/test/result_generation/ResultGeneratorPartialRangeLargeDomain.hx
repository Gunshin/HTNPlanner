package test.result_generation;
import planner.pddl.tree.TreeNode;
import planner.pddl.Domain;
import planner.pddl.Problem;
import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNodeIntFunctionValue;

import planner.pddl.Planner;
import planner.pddl.planner.PlannerActionNode;
import planner.pddl.heuristic.Heuristic;

import planner.pddl.Utilities;

/**
 * ...
 * @author 
 */
class ResultGeneratorPartialRangeLargeDomain implements IResultGenerator
{
	
	static var path:String = "src/test/result_generation/PartialRangeLargeDomain/";
	var domain_path:String = path + "SettlersIntegerParameters.pddl";
	var problem_path:String = path + "problem_file";
	var results_path:String = path + "results.txt";
	
	var repeats:Int = 1;
	
	var ratios:Array<Float> = [
		0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1
	];
	
	var domain_sizes:Array<Int> = [
		10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000
	];
	
	
	public function new() 
	{
		
		
		
	}
	
	public function Run():Bool
	{
		
		Utilities.WriteToFile(results_path, "", false);
		
		var domain:Domain = new Domain(domain_path);
		var problem:Problem = new Problem(problem_path, domain);
		
		var goal_tree:Tree = problem.GetGoalTree();
		var changing_node:TreeNodeIntFunctionValue = cast(goal_tree.GetBaseNode().GetChildren()[0].GetChildren()[1], TreeNodeIntFunctionValue);
		Main.Assert(changing_node.GetParent().toString() == ">= (housing location0) (1) ", "Base problem file has changed: ResultGeneratorPartialRangeLargeDomain");
		
		changing_node.SetValue("" + domain_sizes[9]);
		
		trace(changing_node.toString());
		
		Utilities.WriteToFile(results_path, "Domain: " + domain_path + ",Problem: " + problem_path + "\n", true);
		
		Utilities.WriteToFile(results_path, "Ratio, ", true);
		
		for (ratio in ratios)
		{
			
			Utilities.WriteToFile(results_path, ratio + ",", true);
			var average_times:Float = 0;
			
			for (i in 0...repeats)
			{
				var start:Float = Sys.cpuTime();
				
				var planner:Planner = new Planner();
				var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem, new Heuristic(domain, problem), true, ratio);
				
				average_times += Sys.cpuTime() - start;
			}
			
			Utilities.WriteToFile(results_path, (average_times / repeats) + ",", true);
			Utilities.WriteToFile(results_path, "\n", true);
			trace("done");
		}
		
		/*Utilities.WriteToFile(output_file_, "Time taken seconds: " + (Sys.cpuTime() - start) + "\n", true);
		Utilities.WriteToFile(output_file_, "Plan length: " + array.length + "\n", true);
		Utilities.WriteToFile(output_file_, "Closed list length: " + planner.GetClosedListLength() + " Open list length: " + planner.GetOpenListLength() + "\n", true);
		
		for (i in 0...array.length)
		{
			Utilities.WriteToFile(output_file_, array[i].GetActionTransform() + "\n", true);
		}
		
		Utilities.WriteToFile(output_file_, "\n\n\n", true);*/
		
		
		
		//goal_tree.GetBaseNode().GetChildren()[0].GetChildren()[1]
		return true;
		
	}
	
}