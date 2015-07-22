package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class State
{
	
	var relations:Array<String>;

	public function new() 
	{
		relations = new Array<String>();
	}

	public function AddRelation(relation_:String):Void
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation is null";
		}
		
		if (!Exists(relation_))
		{
			relations.push(relation_);
		}
		
	}
	
	public function RemoveRelation(relation_:String):Bool
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation is null";
		}
		
		return relations.remove(relation_);
	}
	
	public function Exists(relation_:String):Bool
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		//check each element of the relation list
		for (i in relations)
		{
			if (Utilities.Compare(i, relation_) == 0)
			{
				return true;
			}
		}
		
		return false; // we did not find any equivalent strings in the relation list
	}
	
	public function GetMatching(relation_:String):Array<String>
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		var matchingRelations:Array<String> = new Array<String>();
		
		//check each element of the relation list
		for (i in relations)
		{
			if (i.indexOf(relation_) > -1)
			{
				matchingRelations.push(i);
			}
		}
		
		return matchingRelations;
	}
	
	public function Clone():State
	{
		var newState:State = new State();
		
		for (i in relations)
		{
			newState.AddRelation(i);
		}
		
		return newState;
	}
	
}