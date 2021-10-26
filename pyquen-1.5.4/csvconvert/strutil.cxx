#include <strutil.hh>

#include <string>
#include <exception>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <iostream>

namespace StrUtil
{
	void replace_substring(std::string& this_s, const std::string& old_s, const std::string& new_s)
	{
		std::string::size_type pos = 0u;
		while((pos = this_s.find(old_s, pos)) != std::string::npos)
		{
			this_s.replace(pos, old_s.length(), new_s);
			pos += new_s.length();
		}
	}

	void replace_substring(std::string& _s, const char* old_s, const char* new_s)
	{
		std::string sold_s (old_s);
		std::string snew_s (new_s);
		replace_substring(_s, sold_s, snew_s);
	}

	std::string replace_substring_copy(std::string& _s, const char* old_s, const char* new_s)
	{
		std::string sold_s (old_s);
		std::string snew_s (new_s);
		return replace_substring_copy(_s, sold_s, snew_s);
	}

	std::string replace_substring_copy(std::string& this_s, const std::string& old_s, const std::string& new_s)
	{
		std::string copy_s(this_s);
		std::string::size_type pos = 0u;
		while((pos = copy_s.find(old_s, pos)) != std::string::npos)
		{
			copy_s.replace(pos, old_s.length(), new_s);
			pos += new_s.length();
		}
		return copy_s;
	}

	double str_to_double(const char *str, double defret)
	{
		double d = defret;
		try
		{
			d = std::stod(str);
		}
		catch (const std::exception &e)
		{
			// cerr << "[e] " << e.what() << endl;
			// cerr << "    failed to stod >" << str << "<" << endl;
			d = defret;
		}
		return d;
	}

	long str_to_long(const char *str, long defret)
	{
		long d = defret;
		try
		{
			d = std::stol(str);
		}
		catch (const std::exception &e)
		{
			// std::cerr << e.what() << std::endl;
			// std::cerr << "[e] failed to stol (" << str << ")" << std::endl;
			d = defret;
		}
		return d;
	}

	int str_to_int(const char *str, int defret)
	{
		int d = defret;
		try
		{
			d = int(str_to_long(str));
		}
		catch (const std::exception &e)
		{
			// std::cerr << e.what() << std::endl;
			// std::cerr << "[e] failed to int(stol (" << str << ") )" << std::endl;
			d = defret;
		}
		return d;
	}

	std::vector<std::string> split_to_vector(const char *cs, const char *csdelim)
	{
		std::vector<std::string> retv;
		std::string s(cs);
		std::string delimiter(csdelim);
		std::string token;
		size_t pos = 0;
		while ((pos = s.find(delimiter)) != std::string::npos)
		{
		    token = s.substr(0, pos);
		    if (token.size() > 0)
			    retv.push_back(token);
		    s.erase(0, pos + delimiter.length());
		}
		if (s.size() > 0)
		{
			retv.push_back(s);
		}
		return retv;
	}

	Args::Args()
	{
		;
	}

	Args::Args(const char *s)
		: _s(s)
	{
		;
	}

	Args::Args(const std::string &s)
		: _s(s)
	{
		;
	}

	std::string Args::get(const char *swhat, const char *sdefault)
	{
		bool _assigned = false;
		std::string ref(sdefault);
		std::string rval(sdefault);
		if (_s.size() < 1)
		{
			return rval;
		}
		std::vector<std::string> v = split_to_vector(_s.c_str(), " ");
		std::string sw(swhat);
		sw = sw + "=";
		for (unsigned int i = 0; i < v.size(); i++)
		{
			std::string s(v[i]);
			if (s.find(sw, 0) == 0)
			{
				std::vector<std::string> _vs = split_to_vector(s.c_str(), "=");
				if (_vs.size() > 1)
				{
					rval = _vs[1];
				}
				_assigned = true;
			}
		}
		if ((ref == rval) && _assigned == false)
		{
			sw = swhat;
			for (unsigned int i = 0; i < v.size(); i++)
			{
				std::string s(v[i]);
				if (s.find(sw, 0) == 0)
				{
					rval = "True";
				}
			}
		}
		return rval;
	}

	double Args::getBool(const char *swhat)
	{
		std::string s = get(swhat).c_str();
		if (s == "True")
			return true;
		if (s.size() > 0)
			return true;
		return false;
	}

	double Args::getD(const char *swhat, double default_value)
	{
		return str_to_double(get(swhat).c_str(), default_value);
	}

	int Args::getI(const char *swhat, int default_value)
	{
		return str_to_int(get(swhat).c_str(), default_value);
	}

	Args::~Args()
	{
		;
	}

	void Args::_convert(const int argc, const char **argv)
	{
		std::ostringstream ss;
		for (int i = 0; i < argc; i++)
			ss << argv[i] << " ";
		_s = ss.str();
	}

	Args::Args(const int argc, const char **argv)
	{
		_convert(argc, argv);
	}

}
