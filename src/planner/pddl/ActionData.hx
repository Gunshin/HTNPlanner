package planner.pddl;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

import planner.pddl.Planner.ValuesType;

/**
 * ...
 * @author Michael Stephens
 */
class ActionData
{
	
	var parameters:Map<String, Parameter> = new StringMap<Parameter>();
	var parameterLayout:Array<String> = new Array<String>();
	
	var values:Map<String, Value> = new StringMap<Value>();
	var valuesLayout:Array<String> = new Array<String>();

	public function new() 
	{
		
	}
	
	public function GetValue(name_:String):Value
	{
		return values.get(name_);
	}
	
	public function AddValue(value_:Value):Void
	{
		var value:Value = GetValue(value_.GetName());
		if (value != null)
		{
			throw "value already exists!";
		}
		
		values.set(value_.GetName(), value_);
		valuesLayout.push(value_.GetName());
	}
	
	public function SetValue(name_:String, value_:String)
	{
		var value:Value = GetValue(name_);
		if (value == null)
		{
			throw "value is invalid";
		}
		
		value.SetValue(value_);
	}
	
	public function GetValues():Array<Value>
	{
		var vals:Array<Value> = new Array<Value>();
		for (key in values.keys())
		{
			vals.push(values.get(key));
		}
		
		return vals;
	}
	
	public function GetValuesLayout():Array<String>
	{
		return valuesLayout;
	}
	
	public function HasValue(name_:String):Bool
	{
		return values.exists(name_);
	}
	
	public function GetParameterLayout():Array<String>
	{
		return parameterLayout;
	}
	
	public function GetParameterMap():Map<String, Parameter>
	{
		return parameters;
	}
	
	public function GetParameters():Array<Parameter>
	{
		var params:Array<Parameter> = new Array<Parameter>();
		for (key in parameters.keys())
		{
			params.push(parameters.get(key));
		}
		
		return params;
	}
	
	public function AddParameter(name_:String, type_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param != null)
		{
			throw "param already exists";
		}
		
		parameters.set(name_, new Parameter(name_, type_, null));
		parameterLayout.push(name_);
	}
	
	public function SetParameter(name_:String, value_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param == null)
		{
			throw "param is invalid";
		}
		
		param.SetValue(value_);
	}
	
	function GetParameter(name_:String):Parameter
	{
		return parameters.get(name_);
	}
	
	public function SetParameters(values_:Array<Pair<String, String>>)
	{
		for (i in values_)
		{
			SetParameter(i.a, i.b);
		}
	}
	
	/*
	 * This is needed because we have both parameters and values being stored in the same set 'values_', and
	 * we need to differentiate between them
	 */
	public function Set(values_:Array<Pair<String, String>>, types_:Array<ValuesType>)
	{
		for (i in 0...values_.length)
		{
			switch(types_[i])
			{
				case ValuesType.EParam:
					SetParameter(values_[i].a, values_[i].b);
					
				case ValuesType.EValue:
					SetValue(values_[i].a, values_[i].b);
			}
		}
	}
	
}