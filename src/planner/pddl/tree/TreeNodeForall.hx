package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
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

	public function new(children_:Array<RawTreeNode>, domain_:Domain) 
	{
		super();
		
		var pair:Pair<String, String> = Utilities.GenerateValueTypeMap([children_[0]].concat(children_[0].children))[0];
		parameterNode = new Parameter(pair.a, pair.b, "");
		
		forallTree = Tree.ConvertRawTreeNodeToTree(children_[1], domain_);
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		var objects:Array<String> = state_.GetMatching(parameterNode.GetType());
		
		data_.GetParameterMap().set(parameterNode.GetName(), parameterNode);
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			if (!forallTree.Evaluate(data_, state_, domain_))
			{
				return false;
			}
		}
		
		return true;
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{		
		var objects:Array<String> = state_.GetObjectsOfType(parameterNode.GetType());
		
		data_.GetParameterMap().set(parameterNode.GetName(), parameterNode);
		
		for (i in objects)
		{
			parameterNode.SetValue(i);
			
			forallTree.Execute(data_, state_, domain_);
		}
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "forall";
	}
	
}