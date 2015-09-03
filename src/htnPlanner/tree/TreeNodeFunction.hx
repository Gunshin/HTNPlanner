package htnPlanner.tree;
import htnPlanner.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeFunction extends TreeNode
{
	var func:Function = null;
	var paramNames:Array<String> = new Array<String>();

	public function new(func_:Function, params_:Array<RawTreeNode>) 
	{
		super();
		func = func_;
		
		for (param in params_)
		{
			paramNames.push(param.value);
		}
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "Should not be evaluating functions. Use Execute instead which will pass back the variable name";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return func.Construct(data_, paramNames);
	}
	
	public function GetParamNames():Array<String>
	{
		return paramNames;
	}
	
	public function GetRaw():String
	{
		return func.ConstructRaw(paramNames);
	}
	
	override public function GetRawName():String
	{
		return func.GetName();
	}
	
	override public function GetRawTreeString():String
	{
		var returnee:String = func.ConstructRaw(paramNames);
		return returnee;
	}
}