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
	var precondition:Tree = null;
	var effect:Tree = null;

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
		precondition = tree_;
		trace("______________________________________START");
		precondition.Recurse(function(node_) {
			trace(Type.getClassName(Type.getClass(node_)));
		});
		trace("______________________________________END");
	}
	
	public function SetEffectTree(tree_:Tree)
	{
		effect = tree_;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetParameters():Map<String, Parameter>
	{
		return parameters;
	}
	
	public function Evaluate(state_:State, domain_:Domain):Bool
	{
		return precondition.Evaluate(parameters, state_, domain_);
	}
	
	public function Execute(state_:State, domain_:Domain):State
	{
		var cloned:State = state_.Clone();
		effect.Execute(parameters, cloned, domain_);
		return cloned;
	}
	
}