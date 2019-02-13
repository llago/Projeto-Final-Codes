classdef (Sealed, ConstructOnLoad) Configuration < handle & dynamicprops
	
	properties(SetObservable, GetObservable, AbortSet)
	end
	
	methods (Access = private)
		function obj = Configuration
		end
	end
	
	methods (Static)
		function singleObj = getInstance
			persistent localObj
			if isempty(localObj) || ~isvalid(localObj)
				localObj = imq.nmf.Configuration;
			end
			singleObj = localObj;
		end
		
		function obj = loadobj(sobj)
			if isstruct(sobj),
				obj = imq.nmf.Configuration;
				obj = setProperties(obj,sobj);
			end
		end
	end
	
	methods
		function obj = setProperties(obj, cfg)
			if nargin > 0 && isstruct(cfg)
				fields = fieldnames(cfg);
				for i=1:length(fields),
					if ~isprop(obj, fields{i})
						addprop(obj, fields{i});
					end
					
					obj.(fields{i}) = cfg.(fields{i});
				end
			end
		end
		
		function obj = addProperty(obj, property, value)
			if ~isprop(obj, property)
				addprop(obj, property);
			end
			
			obj.(property) = value;
		end
		
		function sobj = saveobj(obj)
			p = properties(obj);
			
			for i=1:length(p),
				sobj.(p{i}) = obj.(p{i});
			end
		end
	end
	
	methods(Access=private)
	end
end