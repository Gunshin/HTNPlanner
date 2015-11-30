package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.Pair;
import planner.pddl.Parameter;
import planner.pddl.RawTreeNode;
import planner.pddl.State;
import planner.pddl.Utilities;
import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeForall extends TreeNode
{
	var parameterNode:Parameter = null;
	var forallTree:Tree = null;
	
	//cache for cloning
	var clone_children:Array<RawTreeNode> = null;
	var clone_domain:Domain = null;

	public function new(children_:Array<RawTreeNode>, domain_:Domain) 
	{
		super();
		
		clone_children = children_;
		clone_domain = domain_;
		
		var pair:Pair<String, String> = Utilities.GenerateValueTypeMap([children_[0]].concat(children_[0].children))[0];
		parameterNode = new Parameter(pair.a, pair.b, "");
		
		forallTree = Tree.ConvertRawTreeNodeToTree(children_[1], domain_);
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		data_.AddExistingParameter(parameterNode);
		
		var flag:Bool = true;
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			//trace(i + "___" + forallTree.Evaluate(data_, state_, domain_));
			
			if (!forallTree.Evaluate(data_, state_, domain_))
			{
				flag = false;
				break;
			}
		}
		
		data_.RemoveParameter(parameterNode.GetName());
		
		return flag;
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{		
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		
		data_.AddExistingParameter(parameterNode);
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			forallTree.Execute(data_, state_, domain_);
		}
		data_.RemoveParameter(parameterNode.GetName());
		
		return null;
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		
		data_.AddExistingParameter(parameterNode);
		
		var flag:Bool = true;
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			if (!forallTree.HeuristicEvaluate(data_, heuristic_data_, state_, domain_))
			{
				flag = false;
				break;
			}
		}
		
		data_.RemoveParameter(parameterNode.GetName());
		
		return flag;
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		
		data_.AddExistingParameter(parameterNode);
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			forallTree.HeuristicExecute(data_, heuristic_data_, state_, domain_);
		}
		
		data_.RemoveParameter(parameterNode.GetName());
		
		return null;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concretes:Array<TreeNode> = new Array<TreeNode>();
		
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		action_data_.AddExistingParameter(parameterNode);
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			concretes = concretes.concat(forallTree.GetBaseNode().GenerateConcrete(action_data_, state_, domain_));
		}
		
		action_data_.RemoveParameter(parameterNode.GetName());
		
		return concretes;
	}
	
	override public function GetRawName():String
	{
		return "forall";
	}
	
	override public function GetRawTreeString():String
	{
		var returnee:String = GetRawName() + " ";
		
		returnee += "(" + forallTree.GetBaseNode().GetRawTreeString() + ") ";
		
		return returnee;
	}
	
	public function GetSubTree():Tree
	{
		return forallTree;
	}
	
	override public function Clone():TreeNode 
	{
		return new TreeNodeForall(clone_children, clone_domain);
	}
	
}