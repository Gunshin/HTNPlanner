package htnPlanner;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	var name:String = null;
	var parameters:Map<String, Parameter> = new StringMap<Parameter>();
	var precondition:Precondition = null;
	var effect:RawTree = null;

	public function new(name_:String)
	{
		name = name_;
	}
	
	//public function Eva
	
	public function AddParameter(name_:String, type_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param != null)
		{
			throw "param already exists";
		}
		
		parameters.set(name_, new Parameter(name_, type_, null));
	}
	
	public function SetParameter(name_:String, value_:String, type_:String, domain:Domain)
	{
		var param:Parameter = GetParameter(name_);
		if (param == null)
		{
			throw "param is invalid";
		}
		
		param.SetValue(value_, type_, domain);
	}
	
	function GetParameter(name_:String):Parameter
	{
		return parameters.get(name_);
	}
	
	public function SetPreconditionTree(tree_:Tree)
	{
		precondition = new Precondition(tree_);
	}
	
	public function SetEffectTree(node_:RawTreeNode)
	{
		effect = new RawTree();
		effect.SetupFromNode(node_);
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetParameters():Map<String, Parameter>
	{
		return parameters;
	}
	
}