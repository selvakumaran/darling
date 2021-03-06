#ifndef UTIL_INICONFIG_H
#define UTIL_INICONFIG_H

#ifdef __cplusplus

#include <map>
#include <string>
#include <vector>
#include <fstream>

class IniConfig
{
public:
	IniConfig(const char* path, bool silentFail = false);
	~IniConfig();
	
	typedef std::map<std::string, std::string> ValueMap;
	typedef std::map<std::string, ValueMap*> SectionMap;

	std::vector<std::string> getSections() const;
	const ValueMap* getSection(const std::string& section) const;

	inline bool hasSection(const std::string& name) const { return getSection(name) != 0; }
protected:
	void loadConfig(std::ifstream& f);
	static std::string& trim(std::string& str);
	static std::string& removeComment(std::string& str);
private:
	SectionMap m_sections;
};

typedef IniConfig* iniconfig_t;
typedef const IniConfig::ValueMap* inivalmap_t;
extern "C" {
#else

typedef struct __iniconfig* iniconfig_t;
typedef struct __inivalmap* inivalmap_t;

#endif

iniconfig_t iniconfig_load(const char* path);
void iniconfig_free(iniconfig_t config);
inivalmap_t iniconfig_getsection(iniconfig_t config, const char* section);
const char* iniconfig_valmap_get(inivalmap_t map, const char* key);

#ifdef __cplusplus
}
#endif

#endif

