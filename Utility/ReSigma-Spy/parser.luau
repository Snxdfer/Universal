--// Parser monolith (bundled from justvvund/roblox-parser sources by KAI)
local Modules = {}
Modules.Parser = (function()
--!strict

type table = {
	[any]: any
}

local Module = {}
Module.__index = Module

function GetDictSize(Dict: table): number
	local Count = 0
	for _ in next, Dict do
		Count += 1
	end
	return Count
end

function Module.new(Values)
	local Class = {}
	return setmetatable(Class, Module)
end

function Module:FormatTableKey(Index): string?
	local Formatter = self.Formatter

	--// Only allow strings for bracket checking
	if typeof(Index) ~= "string" then return end

	--// Check if the data type is allowed
	local NeedsBrackets = Formatter:NeedsBrackets(Index)
	if NeedsBrackets then return end

	return `{Index} = `
end

type ParseTableIntoStringData = {
	Table: table,
	Indent: number?,
	NoBrackets: boolean?,
	NoVariables: boolean?
}
function Module:ParseTableIntoString(Data: ParseTableIntoStringData): (string, number, boolean)
	local Formatter = self.Formatter

	--// Unpack configuration
	local Indent = Data.Indent or 0
	local Table = Data.Table
	local NoBrackets = Data.NoBrackets

	local ItemsCount = GetDictSize(Table)
	local IsArray = true

	--// Empty table
	if ItemsCount == 0 then
		return NoBrackets and "" or "{}", ItemsCount, true
	end

	local IndentString = string.rep("	", Indent)
	local TableString = `{not NoBrackets and "{" or ""}\n`

	--// Generate string
	local Position = 0
	for Index, Value in next, Table do
		Position += 1

		local ValueString = Formatter:Format(Value, Data)
		local IsOrdered = Index == Position

		local Ending = ""
		local KeyString = ""

		--// Format the index value
		if typeof(Index) ~= "number" or not IsOrdered then
			KeyString = self:FormatTableKey(Index)
			IsArray = false
			if not KeyString then
				local IndexString = Formatter:Format(Index, Data)
				KeyString = `[{IndexString}] = `
			end
		end

		--// Check if , should be added to the line
		if Position < ItemsCount then
			Ending = ","
		end

		TableString ..= `{IndentString}	{KeyString}{ValueString}{Ending}\n`
	end

	--// Close the table
	TableString ..= `{IndentString}{not NoBrackets and "}" or ""}`

	return TableString, ItemsCount, IsArray
end

function Module:MakeVariableCodeLine(Data: table): string
	local Name = Data.Name
	local Value = Data.Value
	local Comment = Data.Comment

	local Line = `local {Name} = {Value}`
	local End = Comment and ` -- {Comment}` or ""

	return `{Line}{End}`
end

function Module:MakeVariableCodeLines(ClassDict: table): string
	local Variables = self.Variables

	--// Order variables into array
	local VariablesDict = ClassDict.Variables
	local Ordered = Variables:OrderVariables(VariablesDict)

	--// Compile string
	local Lines = ""
	for Index, Data in Ordered do
		local Line = self:MakeVariableCodeLine(Data)
		Lines ..= `{Line}\n`
	end

	return Lines
end

function Module:MakeVariableCode(Order: table): string
	local Variables = self.Variables
	local ClassedVariables = Variables.VariablesDict

	local Code = ""

	local Index = 0
	for _, Class in next, Order do
		local ClassDict = ClassedVariables[Class]
		if not ClassDict then continue end

		Index += 1

		local NewLine = Index > 1 and "\n" or ""
		Code ..= `{NewLine}-- {Class}\n`
		Code ..= self:MakeVariableCodeLines(ClassDict)
	end

	return Code
end

type MakePathStringData = {
	Object: Instance,
	Parents: table?,
	NoVariables: boolean?
}
function Module:MakePathString(Data: table): (string, number)
	local Variables = self.Variables
	local Formatter = self.Formatter

	local Base = Data.Object
	local Parents = Data.Parents
	local NoVariables = self.NoVariables or Data.NoVariables

	local PathString = ""
	local ParentsCount = 0

	--// Get object parents
	Parents = Parents or Variables:MakeParentsTable(Base, NoVariables)

	local function ServiceCheck(Object: Instance, String: string): boolean?
		local ServiceName = Variables:IsService(Object)
		if not ServiceName then return end

		local ServiceString = `game:GetService("{ServiceName}")`

		--// NoVariables flag
		if NoVariables then
			PathString = ServiceString
			return true
		end

		--// Make service into a variable
		local Name = Variables:MakeVariable({
			Name = ServiceName,
			Class = "Services",
			Value = ServiceString
		})

		PathString = Name
		return true
	end

	--// Make the path string
	for Index, Object in next, Parents do
		local String = Formatter:ObjectToString(Object)

		--// Check for an existing variable
		local Variable = Variables:GetVariable(Object)
		if Variable and not NoVariables then
			String = Variable.Name
		end

		--// Check if the object is a service
		if Index == 2 and Parents[1] == game then
			if ServiceCheck(Object, String) then continue end
		end

		local Brackets = Formatter:NeedsBrackets(String)
		local Separator = Index > 1 and "." or ""

		ParentsCount += 1
		PathString ..= Brackets and `["{String}"]` or `{Separator}{String}`
	end

	--// Cache path
	-- PathCache[Object] = {
	-- 	Variables = Variables,
	-- 	Args = {PathString, #Parents}
	-- }

	return PathString, ParentsCount
end

return Module
end)()
Modules.Formatter = (function()
type table = {
	[any]: any
}

local Module = {}
Module.__index = Module

--// Defaults
local DefaultTween = TweenInfo.new()
local GetServerTimeNow = workspace.GetServerTimeNow

Module.ClassNameStrings = {
	["DataModel"] = "game",
	["Workspace"] = "workspace",
	["Stats"] = "stats()",
	["GlobalSettings"] = "settings()",
	["PluginManagerInterface"] = "PluginManager()",
	["UserSettings"] = "UserSettings()",
	["DebuggerManager"] = "DebuggerManager()"
}

--// Format type functions
Module.Formats = {
	["CFrame"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, false, true)
		return `CFrame.new({Arguments})`
	end,
	["Vector3"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value)
		return `Vector3.new({Arguments})`
	end,
	["Vector2"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, true)
		return `Vector2.new({Arguments})`
	end,
	["Vector2int16"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, true)
		return `Vector2int16.new({Arguments})`
	end,
	["Vector3int16"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value)
		return `Vector3int16.new({Arguments})`
	end,
	["Color3"] = function(self, Value)
		return `Color3.fromRGB({Value.R*255}, {Value.G*255}, {Value.B*255})`
	end,
	["NumberRange"] = function(self, Value)
		local Min = self:Format(Value.Min)
		local Max = self:Format(Value.Max)
		return `NumberRange.new({Min}, {Max})`
	end,
	["NumberSequenceKeypoint"] = function(self, Value)
		return `NumberSequenceKeypoint.new({Value.Time}, {Value.Value}, {Value.Envelope})`
	end,
	["ColorSequenceKeypoint"] = function(self, Value)
		return `ColorSequenceKeypoint.new({Value.Time}, {Value.Value})`
	end,
	["PathWaypoint"] = function(self, Value)
		local Position = self:Format(Value.Position)
		local Action = `Enum.PathWaypointAction.{Value.Action.Name}`
		return `PathWaypoint.new({Position}, {Action}, "{Value.Label}")`
	end,
	["PhysicalProperties"] = function(self, Value)
		return `PhysicalProperties.new("{Value.Density}, {Value.Friction}, {Value.Elasticity}, {Value.FrictionWeight}, {Value.ElasticityWeight}`
	end,
	["Ray"] = function(self, Value)
		local Origin = self:Format(Value.Origin)
		local Direction = self:Format(Value.Direction)
		return `Ray.new({Origin}, {Direction})`
	end,
	["UDim2"] = function(self, Value)
		return `UDim2.new({Value.X.Scale},{Value.X.Offset},{Value.Y.Scale},{Value.Y.Offset})`
	end,
	["UDim"] = function(self, Value)
		return `UDim2.new({Value.Scale},{Value.Offset})`
	end,
	["BrickColor"] = function(self, Value)
		return `BrickColor.new("{Value.Name}")`
	end,
	["buffer"] = function(self, Value)
		local String = buffer.tostring(Value)
		String = self:Format(String)
		return `buffer.fromstring({String}) --[[{Value}]]`
	end,
	["DateTime"] = function(self, Value)
		return `DateTime.fromUnixTimestampMillis({Value.UnixTimestampMillis})`
	end,
	["Enum"] = `%*`,
	["string"] = function(self, Value)
		local Filtered = self:MakePrintable(Value)
		local FormatBase = `"%*"`

		local HasBrackets = Filtered:find("%[%[=*[[]")
		local HasNewLine = Filtered:find("[\n\r]")

		if not HasBrackets and HasNewLine then
			FormatBase = "[[%*]]"
		end

		return FormatBase:format(Filtered)
	end,
	["number"] = `%*`,
	["TweenInfo"] = function(self, Value)
		local Style = `Enum.EasingStyle.{Value.EasingStyle.Name}`
		local Direction = `Enum.EasingDirection.{Value.EasingDirection.Name}`

		local IsDefaultStyle = Value.EasingStyle == DefaultTween.EasingStyle 
		local IsDefaultDirection = Value.EasingDirection == DefaultTween.EasingDirection

		if IsDefaultStyle and IsDefaultDirection then
			return `TweenInfo.new({Value.Time})`
		end

		return `TweenInfo.new({Value.Time}, {Style}, {Direction})`
	end,
	["boolean"] = `%*`,
	["Instance"] = function(self, Object: Instance)
		local Path, Length = self.Parser:MakePathString({
			Object = Object
		})
		return Path, Length > 2
	end,
	["function"] = function(self, Value)
		local Name = debug.info(Value, "n")
		local String = ""

		if #Name <= 0 then
			String = `{Value}`
		else
			String = `function {Name}`
		end

		return `nil --[[{String}]]`
	end,
	["table"] = function(self, Value, Data)
		local Indent = Data.Indent or 0
		local Parsed = self.Parser:ParseTableIntoString({
			NoBrackets = false,
			Indent = Indent + 1,
			Table = Value
		})
		return Parsed
	end,
	["RBXScriptSignal"] = function(self, Value, Data)
		local Name = tostring(Value):match(" (%a+)")
		return `nil --[[Signal: {Name}]]`
	end,
}

function Module:IsPrintable(Character: string, NoNewlines: boolean)
	--// Disallow \n and \r (return)
	if NoNewlines then
		return Character:match("[%g ]")
	end

	return Character:match("[\n\r%g ]")
end

function Module:MakePrintable(String: string, NoNewlines: boolean): string
	local Filtered = String:gsub("\"", [[\"]])

	return Filtered:gsub(".", function(Character: string)
		if NoNewlines then
			Character = Character:gsub("\n", "\\n")
			Character = Character:gsub("\r", "\\r")
		end

		--// Printable character
		if self:IsPrintable(Character, NoNewlines) then
			return Character
		end

		--// Format non-printable characters by /hex
		return `\\{Character:byte()}`
	end)
end

function Module:FormatVectorValues(Vector, ...): string
	local Values = {self:RoundVector(Vector, ...)}
	return table.concat(Values, ", ")
end

function Module:RoundValues(Table: table): table
	local RoundedTable = {}
	
	for _, Value in next, Table do
		local Rounded = math.round(Value)
		table.insert(RoundedTable, Rounded)
	end
	
	return RoundedTable
end

function Module:RoundVector(Vector, IsVector2: boolean?, IsCFrame: boolean?): (number, number, number?)
	local X, Y, Z = Vector.X, Vector.Y, not IsVector2 and Vector.Z or 0

	if IsCFrame then
		local Components = {Vector:GetComponents()}
		return unpack(self:RoundValues(Components))
	end

	return math.round(X), math.round(Y), not IsVector2 and math.round(Z) or nil
end

function Module:GetServerTimeNow(): number
	return GetServerTimeNow(workspace)
end

function Module:MakeReplacements(Timestamp: number): table
	local Delay = tick() - (Timestamp or tick())

	--// Time specific
	local ServerTime = math.round(self:GetServerTimeNow() - Delay)
	local GameTime = math.round(workspace.DistributedGameTime - Delay)

	--// Replacement wrapper
	local Replacements = {}
	local function AddReplacement(Key, Replacement)
		--// Negitive version
		if typeof(Key) == "number" then
			Replacements[-Key] = `-{Replacement}`
		end
		
		Replacements[Key] = Replacement
	end

	--// Replacements
	AddReplacement(Vector2.one, "Vector2.one")
	AddReplacement(Vector2.zero, "Vector2.zero")
	AddReplacement(Vector3.one, "Vector3.one")
	AddReplacement(Vector3.zero, "Vector3.zero")
	AddReplacement(math.huge, "math.huge")
	AddReplacement(math.pi, "math.pi")
	AddReplacement(workspace.Gravity, "workspace.Gravity")
	AddReplacement(workspace.AirDensity, "workspace.AirDensity")
	AddReplacement(workspace.CurrentCamera.CFrame, "workspace.CurrentCamera.CFrame")
	AddReplacement(GameTime, "workspace.DistributedGameTime")
	AddReplacement(ServerTime, "workspace:GetServerTimeNow()")

	return Replacements
end

function Module:SetValueSwaps(ValueSwaps: table)
	self.ValueSwaps = ValueSwaps
end

function Module:FindStringIntSwap(Value: string)
	--// Check if string is a int
	local Int = tonumber(Value)
	if not Int then return end

	--// Find a swap for the int value
	local Swap = self:FindValueSwap(Int)
	return Swap
end

function Module:FindValueSwap(Value)
	local ValueSwaps = self.ValueSwaps

	--// Lookup replacement in ValueSwaps
	local Replacement = ValueSwaps[Value]
	if Replacement then return Replacement end

	--// String formatting
	if typeof(Value) == "string" then
		local Swap = self:FindStringIntSwap(Value)
		if Swap then
			return `tostring({Swap})`
		end
	end

	--// Check if the value is a number
	local IsNumber = typeof(Value) == "number"
	if not IsNumber then return end

	--// Round the number up
	local Rounded = math.round(Value)
	return ValueSwaps[Rounded]
end

function Module:NeedsBrackets(String: string)
	if not String then return end

	--// Only allow strings for bracket checking
	if typeof(String) ~= "string" then 
		return true
	end

	return not String:match("^[%a_][%w_]*$")
end

function Module:MakeName(Value): string?
	local Name = self:ObjectToString(Value)
	Name = Name:gsub("[./ #%@$%£+-()\n\r]", "")
	Name = self:MakePrintable(Name, true)

	--// Check if the name can be used for a variable
	if self:NeedsBrackets(Name) then return end

	--// Prevent long and short variable names
	if #Name < 1 or #Name > 30 then return end

	return Name
end

function Module.new(Values: table): table
	local Base = {}
	local Class = setmetatable(Base, Module)
	Class.ValueSwaps = Class:MakeReplacements()

	return Class
end

type FormatExtra = {
	NoVariables: boolean?,
	Indent: number?
}
function Module:Format(Value, Extra)
	local Formats = self.Formats
	local Variables = self.Variables

	Extra = Extra or {}
	local NoVariables = self.NoVariables or Extra.NoVariables
	
	--// Check for a value swap
	local Swap = self:FindValueSwap(Value)
	if Swap then return Swap end

	local Type = typeof(Value)
	local Format = Formats[Type]
	local Name = nil

	--// Variable name based on Instance name
	if typeof(Value) == "Instance" then
		Name = self:MakeName(Value)
	end

	--// Invoke compile function
	if typeof(Format) == "function" then
		local Formatted, IsVariable = Format(self, Value, Extra)

		--// Make variable
		if IsVariable and not NoVariables then
			Formatted = Variables:MakeVariable({
				Name = Name,
				Lookup = Value,
				Value = Formatted
			})
		end

		return Formatted
	end

	--// Check if the data-type is supported
	if not Format then
		return `{Value} --[[{Type} not supported]]`
	end

	return Format:format(Value)
end

function Module:ObjectToString(Object: instance): string
	local Swaps = self.Swaps
	local IndexFunc = self.IndexFunc
	local Replacements = self.ClassNameStrings

	local Name = IndexFunc(Object, "Name")
	local ClassName = IndexFunc(Object, "ClassName")

	local Replacement = Replacements[ClassName]
	local String = Replacement or Name
	String = self:MakePrintable(String, true)

	--// Check for swaps
	if Swaps then
		local Swap = Swaps[Object]
		if Swap then
			String = Swap.String
		end
	end

	return String
end

return Module
end)()
Modules.Variables = (function()
--!strict

type VariableData = {
	Name: string,
	Value: any,
	Order: number,
	Lookup: any?,
	Class: string?,
	Comment: string?
}

type Table = {
	[any]: any
}

type VariablesDict = {
	[any]: VariableData
}

export type ClassDict = {
	VariableCount: number,
	Variables: VariablesDict
}

type Module = {
	VariablesDict: Table,
	VariableLookup: Table,
	InstanceQueue: Table,
	NoNameCount: number,
	VariableBase: string
}

--// Module
local Module = {
	VariableBase = "Jit"
}
Module.__index = Module

local Globals = getfenv(1)

--// Variable pre-render functions 
local RenderFuncs = {
	["Instance"] = function(self, Items: Table)
		local Parser = self.Parser
		local Formatter = self.Formatter

		local AllParents = self:BulkCollectParents(Items)
		local Duplicates = self:FindDuplicates(AllParents)

		--// Make duplicates into variables
		for _, Object: Instance in next, Duplicates do
			local Path, ParentsCount = Parser:MakePathString({
				Object = Object
			})

			--// Check the parent count to prevent single paths
			if ParentsCount < 3 then continue end

			local Name = Formatter:MakeName(Object)

			--// Make variable
			self:MakeVariable({
				Lookup = Object,
				Name = Name,
				--Comment = "Compressed duplicate",
				Value = Path
			})
		end
	end,
}

local function MultiInsert(Table: Table, ToInsert: Table)
	for _, Value in next, ToInsert do
		table.insert(Table, Value)
	end
end

function Module.new(Values)
	local Class = {
		VariablesDict = {},
		VariableLookup = {},
		InstanceQueue = {},
		VariableNames = {},
		NoNameCount = 0
	}
	return setmetatable(Class, Module)
end

function Module:GetNoNameCount(): number
	return self.NoNameCount
end

function Module:AddVariableToClass(ClassDict: ClassDict, Data: VariableData)
	--// Variable data
	local Value = Data.Value
	local Lookup = Data.Lookup or Value

	ClassDict.VariableCount += 1

	--// Class data
	local Position = ClassDict.VariableCount
	local Variables = ClassDict.Variables

	Data.Order = Position
	Variables[Lookup] = Data
end

function Module:GetClassDict(Class: string): ClassDict
	local Variables = self.VariablesDict
	local ClassDict = Variables[Class]

	--// Return existing
	if ClassDict then return ClassDict end

	--// Create class dict
	ClassDict = {
		VariableCount = 0,
		Variables = {}
	}

	Variables[Class] = ClassDict
	return ClassDict
end

function Module:IsGlobal(Value: (string|Instance)): (string|boolean)
	local IndexFunc = self.IndexFunc

	--// Check based on instance name
	if typeof(Value) == "Instance" then
		local Name = IndexFunc(Value, "Name")
		return Globals[Name] == Value
	end

	return Globals[Value] and Value or false
end

function Module:IsService(Object: Instance): (string|boolean)
	local IndexFunc = self.IndexFunc
	local ClassName = IndexFunc(Object, "ClassName")

	--// Check if object is a service based on the ClassName
	local Success = pcall(function()
		return game:GetService(ClassName)
	end)

	return Success and ClassName or false
end

function Module:IncreaseNameUseCount(Name: string): number
	if not Name then return 0 end

	local VariableNames = self.VariableNames	
	local NameUseCount = VariableNames[Name]

	--// Create missing dict
	if not NameUseCount then
		NameUseCount = 0
		VariableNames[Name] = NameUseCount
	end

	VariableNames[Name] += 1

	return NameUseCount
end

function Module:IncreaseNoNameCount(): number
	self.NoNameCount += 1
	return self.NoNameCount
end

function Module:CheckName(Data): string
	local Name = Data.Name
	local NameUseCount = self:IncreaseNameUseCount(Name)

	--// Check if the variable already has defined name
	if Name then
		if NameUseCount <= 0 then 
			return Name 
		else
			return `{Name}{NameUseCount}`
		end
	end

	--// Create a default variable name
	local NoNameCount = self:IncreaseNoNameCount()

	--// Format VariableBase string
	local Base = self.VariableBase
	return Base:format(NoNameCount)
end

function Module:GetVariable(Value): VariableData?
	local VariableLookup = self.VariableLookup
	return VariableLookup[Value]
end

function Module:OrderVariables(Variables: VariablesDict): Table
	local Ordered = {}

	for Lookup, Data in next, Variables do
		local Order = Data.Order
		table.insert(Ordered, Order, Data)
	end

	return Ordered
end

function Module:MakeVariable(Data: VariableData): string
	local VariableLookup = self.VariableLookup
	local InstanceQueue = self.InstanceQueue

	local Value = Data.Value
	local Lookup = Data.Lookup or Value
	local Class = Data.Class or "Variables"

	--// Return existing variable
	local Existing = self:GetVariable(Lookup)
	if Existing then
		return Existing.Name
	end

	--// Check if the value is a global
	local Global = self:IsGlobal(Value)
	if Global then
		return Global
	end

	--// Check if value is an instance
	if not Data.Name and typeof(Value) == "Instance" then
		InstanceQueue[Value] = Data
	end

	--// Generate variable name
	local Name = self:CheckName(Data)
	Data.Name = Name

	--// Check variable class dict
	local ClassDict = self:GetClassDict(Class)
	self:AddVariableToClass(ClassDict, Data)

	VariableLookup[Lookup] = Data
	return Name
end

function Module:CollectTableItems(Table: Table, Callback: (Value: any)->nil)
	local function Process(Value)
		local Type = typeof(Value)

		--// Recursive search
		if Type == "table" then
			self:CollectTableItems(Value, Callback)
			return
		end

		Callback(Value)
	end

	--// Process each item in table
	for A, B in next, Table do
		Process(A)
		Process(B)
	end
end

function Module:FindDuplicates(Table: Table): Table
	local Duplicates = {}
	local IndexStates = {}

	for Index, Value in next, Table do
		local State = IndexStates[Value]

		--// Check if the value has already been indexed
		if State == 1 then
			IndexStates[Value] = 2
			table.insert(Duplicates, Value)
			continue
		end

		IndexStates[Value] = 1
	end

	--// Clear index states in memory
	table.clear(IndexStates)

	return Duplicates
end

function Module:CollectTableTypes(Table: Table, Types: Table): Table
	local Collections = {}

	local function Process(Value)
		local Type = typeof(Value)

		--// Check if type should be collected
		if not table.find(Types, Type) then return end

		local Collected = Collections[Type]
		if not Collected then
			Collected = {}
			Collections[Type] = Collected
		end

		table.insert(Collected, Value)
	end

	--// Collect all table items
	self:CollectTableItems(Table, Process)

	return Collections
end

function Module:MakeParentsTable(Object: Instance, NoVariables: boolean?): Table
	local IndexFunc = self.IndexFunc
	local Swaps = self.Swaps
	local Variables = self.Variables
	NoVariables = self.NoVariables or NoVariables

	local Parents = {}
	local NextParent = Object :: Instance?

	while true do
		local Current = NextParent
		NextParent = IndexFunc(NextParent, "Parent")

		--// Global check
		if NextParent == game and self:IsGlobal(Current) then
			NextParent = nil
		end

		--// Check for swaps
		if Swaps then
			local Swap = Swaps[Current]
			if Swap and Swap.NextParent then
				NextParent = Swap.NextParent
			end
		end

		--// Check for a variable with the path
		local Variable = Variables:GetVariable(Current)
		if not NoVariables and Variable and NextParent then
			NextParent = nil
		end

		table.insert(Parents, 1, Current)

		--// Break if no parent
		if not NextParent then break end
	end

	return Parents
end

function Module:BulkCollectParents(Objects: Table): (Table, Table)
	local AllParents = {}
	local ObjectParents = {}

	--// Collect all parents
	for _, Object in next, Objects do
		if typeof(Object) ~= "Instance" then continue end

		local Parents = self:MakeParentsTable(Object)
		MultiInsert(AllParents, Parents)
		ObjectParents[Object] = Parents
	end

	return AllParents, ObjectParents
end

function Module:PrerenderVariables(Table: Table, Types: Table)	
	--// Disable compression if NoVariables is enabled
	if self.NoVariables then return end

	--// Collect keys and values in table
	local Collections = self:CollectTableTypes(Table, Types)

	--// Instances
	for Type, Items in next, Collections do
		local Render = RenderFuncs[Type]
		if Render then
			Render(self, Items)
		end
	end
end

return Module
end)()
local Module = (function()
--!strict

--[[
    Written by depso
    GNU GPLv3 License
    
    https://github.com/depthso
]]

type Table = {
	[any]: any 
}

local Module = {
	--// Package data
	Version = "1.1.2",
	Author = "Depso",
	License = "GNU-GPLv3",
	Repository = "https://github.com/justvvund/roblox-parser",
	ImportUrl = "https://raw.githubusercontent.com/justvvund/roblox-parser/refs/heads/main",

	Modules = {}
}

--// Import modules
local ImportModules = {
	"Parser",
	"Formatter",
	"Variables"
}

local function MergeDict(Base: Table, New: Table)
	for Key, Value in next, New do
		Base[Key] = Value
	end
end

--// This can be replaced
function Module:Import(Name: string)
	local Script = script:FindFirstChild(Name)
	return require(Script)
end

function Module:Load()
	local Modules = self.Modules

	for _, Name in next, ImportModules do
		Modules[Name] = self:Import(Name)
	end

	return self
end

function Module:New(Data: Table): Table
	local Modules = self.Modules

	local Class = {
		Variables = Modules.Variables.new(),
		Formatter = Modules.Formatter.new(),
		Parser = Modules.Parser.new()
	}

	--// Merge passed data with the shared class data
	if Data then
		MergeDict(Class, Data)
	end

	--// Merge class modules
	for Name, Value in next, Class do
		if typeof(Value) ~= "table" then continue end

		if Value.new then
			MergeDict(Value, Class)
		end
	end

	return Class
end

return Module

end)()
Module.Modules = Modules
function Module:Import(Name) return Modules[Name] end
Module:Load()
return Module
