package htnPlanner;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Problem
{
	var problemName:String = null;
	
	var problemTree:RawTree = null;
	
	var domainName:String = null;
	var domain:Domain = null;
	
	var initialState:State = new State();
	var objects:Map<String, Array<String>> = new Map<String, Array<String>>();
	
	var goal:Tree = null;
	
	var metric:Tree = null;
	
	var properties:Map<String, Bool> = new Map<String, Bool>();

	public function new(problemFilePath_:String, domain_:Domain) 
	{
		domain = domain_;
		
		problemTree = new RawTree();
		problemTree.SetupFromString(Utilities.CleanFileImport(problemFilePath_));
		
		// this gets the scope of the problem name, which only returns an array with a single element as there
		// are never 2 definitions for the problem name. We then split this value into two strings due to the value
		// being eg. "problem truck-12", where truck-12 is the name we want.
		problemName = problemTree.GetBaseNode().GetChildrenWithContainingValue("problem")[0].value.split(" ")[1];
		
		// same as above eg. ":domain Trucks"
		domainName = problemTree.GetBaseNode().GetChildrenWithContainingValue(":domain")[0].value.split(" ")[1];
		
		ParseObjects(problemTree.GetBaseNode().GetChildrenWithContainingValue(":objects")[0]);
		
		ParseInit(problemTree.GetBaseNode().GetChildrenWithContainingValue(":init")[0]);
		
		ParseGoal(problemTree.GetBaseNode().GetChildrenWithContainingValue(":goal")[0]);
		
		var metric:Array<RawTreeNode> = problemTree.GetBaseNode().GetChildrenWithContainingValue(":metric");
		if (metric.length > 0)
		{
			ParseMetric(metric[0]);
		}
	}
	
	function ParseObjects(node_:RawTreeNode)
	{
		for (type in domain.GetTypes().GetAllTypes())
		{
			objects.set(type, new Array<String>());
		}
		
		var objArray:Array<Pair> = Utilities.GenerateValueTypeMap(node_.value.split(" ").slice(1));
		
		for (obj in objArray)
		{
			var typeList:Array<String> = domain.GetTypes().GetTypesHierarchy(obj.b);
			
			for (type in typeList)
			{
				var objectsArray:Array<String> = objects.get(type);
				objectsArray.push(obj.a);
			}
		}
		
		// we also need to iterate through the domains constant list if it has one, and add it to the object list (for now)
		for (constant in domain.GetConstants())
		{
			var typeList:Array<String> = domain.GetTypes().GetTypesHierarchy(constant.b);
			
			for (type in typeList)
			{
				var objectsArray:Array<String> = objects.get(type);
				objectsArray.push(constant.a);
			}
		}
		
		properties.set("objects", true);
	}
	
	function ParseInit(node_:RawTreeNode)
	{
		var andNode:RawTreeNode = new RawTreeNode(node_);
		andNode.value = "and";
		andNode.children = node_.children;
		
		node_.children = new Array<RawTreeNode>();
		node_.children.push(andNode);
		
		var tree:Tree = Tree.ConvertRawTreeNodeToTree(andNode, domain);
		tree.Execute(null, initialState, domain);
		
		properties.set("init", true);
	}
	
	function ParseGoal(node_:RawTreeNode)
	{
		// for now just leaving goal as a tree that can be evaluated
		goal = Tree.ConvertRawTreeNodeToTree(node_.children[0], domain);
		
		properties.set("goal", true);
	}
	
	function ParseMetric(node_:RawTreeNode)
	{
		metric = Tree.ConvertRawTreeNodeToTree(node_.children[0], domain);
		
		properties.set("metric", true);
		
		if (Utilities.Compare(node_.value.split(" ")[1], "minimize") == 0)
		{
			properties.set("minimize", true);
		}
		else
		{
			properties.set("maximize", true);
		}
	}
	
	public function EvaluateGoal(state_:State):Bool
	{
		return goal.Evaluate(null, state_, domain);
	}
	
	public function EvaluateMetric(state_:State):Int
	{
		return Std.parseInt(metric.Execute(null, state_, domain));
	}
	
	public function GetClonedInitialState():State
	{
		return initialState.Clone();
	}
	
	public function HasProperty(string_:String):Bool
	{
		return properties.exists(string_);
	}
	
	public function GetObjectsOfType(type_:String):Array<String>
	{
		return objects.get(type_);
	}
	
	
}