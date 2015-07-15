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

	public function AddRelation(relations_:String):Void
	{
		if (relations_ == null || relations_.length == 0)
		{
			return;
		}
		
		if (!Exists(relations_))
		{
			relations.push(relations_);
		}
		
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
	
	/*
	 * 
	 * Since this function can be used to get all relations that match from a substring of relations,
	 * there is a need to retunr an array.
	 * 
	 * eg.
	 * Conained relations:
	 * ["Inventory", "Logs", "10"]
	 * ["Inventory", "Axe", "1"]
	 * ["Health", "100"]
	 * 
	 * With matching relation array:
	 * ["Inventory", "Logs"]
	 * 
	 * Will return:
	 * [["Inventory", "Logs", "10"]]
	 * 
	 * Or with:
	 * ["Inventory"]
	 * 
	 * Will return:
	 * [["Inventory", "Logs", "10"], ["Inventory", "Axe", "1"]]
	 * 
	 */
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
	
}