package test;

import haxe.Timer;
import planner.pddl.Action;

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
	
	//var domainLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/NumRover.pddl";
	//var problemLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/pfile1";
	var domainLocation:String = "pddlexamples/runescape/domain.pddl";
	var problemLocation:String = "pddlexamples/runescape/p1.pddl";
	
	public function new()
	{
		//UnitTests();
		
		var domain = new Domain(domainLocation);
		var problem = new Problem(problemLocation, domain);
		
		var nodes:Array<TreeNode> = new Array<TreeNode>();
		domain.GetAction("Cut_Down_Tree").GetPreconditionTree().Recurse(
			function(node)
			{
				if (Utilities.Compare(node.GetRawName(), "and") == 0 || Utilities.Compare(node.GetRawName(), "or") == 0)
				{
					var count:Int = 0;
					
					for (child in node.GetChildren())
					{
						Tree.Recursive(
							function(testNode)
							{
								if (Utilities.Compare(testNode.GetRawName(), "~count") == 0)
								{
									count++;
									return false;
								}
								
								return true;
							}
						, child);
					}
					
					if (count > 1)
					{
						nodes.push(node);
					}
				}
				
				return true;
			}
		);
		
		trace(nodes.length);
		
		var prec:Array<String> = new Array<String>();
		
		for (node in nodes)
		{
			prec.push(node.GetRawTreeStringFiltered(
				function(child)
				{
					var flag:Bool = false;
					Tree.Recursive(
						function(testNode)
						{
							if (Utilities.Compare(testNode.GetRawName(), "~count") == 0)
							{
								flag = true;
							}
							
							return true;
						}
					, child);
					return flag;
				}
			));
		}
		
		for (ele in prec)
		{
			trace(ele);
		}
		
		//domain.GetAction("Cut_Down_Tree").GetData().GetValue("~count").SetLowerBound(1);
		//domain.GetAction("Cut_Down_Tree").GetData().GetValue("~count").SetUpperBound(28);
		
		/*var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].GetActionTransform());
		}*/
		
	}
	
	public function UnitTests()
	{
		var domain:Domain = new Domain("src/test/runescape/domain.pddl");
		var problem = new Problem("src/test/runescape/p1.pddl", domain);
		
		trace("Starting Action Tests");
		var action:Action = domain.GetAction("Cut_Down_Tree");
		
		Assert((action != null), "Could not find action");
		Assert((action.GetData().GetParameterMap().exists("?resource")), "Could not find parameter");
		Assert((action.GetData().GetValue("~count") != null), "Could not find value");
		
		trace("Starting Plan Test");		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
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