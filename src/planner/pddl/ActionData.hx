package planner.pddl;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

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
	
	public function SetValues(values_:Array<Pair<String, String>>)
	{
		for (i in values_)
		{
			SetValue(i.a, i.b);
		}
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
	
	public function AddExistingParameter(param_:Parameter)
	{
		var param:Parameter = GetParameter(param_.GetName());
		if (param != null)
		{
			throw "param already exists";
		}
		
		parameters.set(param_.GetName(), param_);
		parameterLayout.push(param_.GetName());
	}
	
	public function RemoveParameter(name_:String):Bool
	{
		parameterLayout.remove(name_);
		return parameters.remove(name_);
	}
	
	public function SetParameter(name_:String, value_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param == null)
		{
			throw "param is null: " + name_ + " _ value: " + value_ + " ::: " + this;
		}
		
		param.SetValue(value_);
	}
	
	public function GetParameter(name_:String):Parameter
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
	
	public function toString():String
	{
		var string:String = "{\"parameters\":[";
		
		for (param in parameters.keys())
		{
			string += parameters.get(param) + ",";
		}
		
		string = string.substr(0, string.length - 1);
		string += "], \"parameters_layout\":[";
		
		for (param in parameterLayout)
		{
			string += "\"" + param + "\",";
		}
		
		string = string.substr(0, string.length - 1);
		string += "], \"values\":[";
		
		for (value in values.keys())
		{
			string += values.get(value) + ",";
		}
		
		string = string.substr(0, string.length - 1);
		string += "], \"values_layout\":[";
		
		for (value in valuesLayout)
		{
			string += "\"" + value + "\",";
		}
		
		string = string.substr(0, string.length - 1);
		string += "]}";
		
		return string;
	}
	
}