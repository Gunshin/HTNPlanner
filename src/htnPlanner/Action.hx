package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	var name:String = null;
	var parameters:Array<Parameter> = new Array<Parameter>();
	var precondition:Tree = null;
	var effect:Tree = null;

	public function new(name_:String)
	{
		name = name_;
	}
	
	public function AddParameter(name_:String, type_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param != null)
		{
			throw "param already exists";
		}
		
		parameters.push(new Parameter(name_, type_, null));
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
		for (i in parameters)
		{
			if (Utilities.Compare(name_, i.GetName()) == 0)
			{
				return i;
			}
		}
		
		return null;
	}
	
	public function SetPreconditionTree(node_:TreeNode)
	{
		precondition = new Tree();
		precondition.SetupFromNode(node_);
	}
	
	public function SetEffectTree(node_:TreeNode)
	{
		effect = new Tree();
		effect.SetupFromNode(node_);
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetParameters():Array<Parameter>
	{
		return parameters;
	}
	
}