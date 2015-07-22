package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNode
{
	
	var parent:TreeNode = null;
	var children:Array<TreeNode> = new Array<TreeNode>();

	public function new() 
	{
		
	}
	
	public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool { throw "must override this function"; }
	
	public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String { throw "must override this function"; }
	
	public function AddChild(child_:TreeNode)
	{
		children.push(child_);
	}
	
	public function SetParent(parent_:TreeNode)
	{
		parent = parent_;
	}
	
}