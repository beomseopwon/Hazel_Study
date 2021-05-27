--lua는 "--"가 주석입니다.

workspace "Hazel"           --솔루션파일 이름
	architecture "x86_64"   --솔루션의 architecture, 32bit인지 64bit인지 설정

	configurations          --구성 (debug모드, release모드 등 어떤 구성이 있는지?)
	{
		"Debug",
		"Release",
		"Dist"
	}

 --결과물 폴더경로를 outputdir변수에 저장
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"  

project "Hazel"      --프로젝트 이름
	location "Hazel" 
	kind "SharedLib" -- 빌드후 생성되는 파일의 종류 (ex. 실행파일(exe)인지 라이브러리인지(lib or dll)
	language "C++"   -- 사용언어

	targetdir ("bin/" .. outputdir .. "/%{prj.name}")  --생성파일(exe,lib,dll) 경로설정
	objdir ("bin-int/" .. outputdir .. "/%{prj.name}") --obj파일경로 설정

	pchheader "hzpch.h"
	pchsource "Hazel/src/hzpch.cpp"

	files  --어떤파일을 컴파일 할 것인지?
	{
		"%{prj.name}/src/**.h",  -- 프로젝트이름폴더-> src폴더안에있는 모든 헤더파일들
		"%{prj.name}/src/**.cpp" -- 위와 동일한 경로에 있는 모든 cpp파일들
	}

	includedirs   --추가포함 디렉토리경로 설정
	{
		"%{prj.name}/src",
		"%{prj.name}/vendor/spdlog/include"
	}

	filter "system:windows" -- 특정환경에 대한 설정 (ex window환경 )
		cppdialect "C++17"
		staticruntime "On"  
		systemversion "latest"  --윈도우버전을 최신으로 설정

		defines  --전처리기 설정.
		{
			"HZ_PLATFORM_WINDOWS", --Hazel프로젝트에는 이러한 전처리가 있다.
			"HZ_BUILD_DLL"
		}

		postbuildcommands
		{
			("{COPY} %{cfg.buildtarget.relpath} ../bin/" .. outputdir .. "/Sandbox")
		}

	filter "configurations:Debug" --디버그구성일 때 설정
		defines "HZ_DEBUG"
		symbols "On"

	filter "configurations:Release" --릴리즈일때..
		defines "HZ_RELEASE"
		optimize "On"

	filter "configurations:Dist"   -- dist구성일때..
		defines "HZ_DIST"
		optimize "On"

project "Sandbox"   --프로젝트 이름 (현재 솔루션안에는 Hazel과 Sandbox프로젝트가있다.)
	location "Sandbox"
	kind "ConsoleApp"
	language "C++"

	targetdir ("bin/" .. outputdir .. "/%{prj.name}")
	objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

	files
	{
		"%{prj.name}/src/**.h",
		"%{prj.name}/src/**.cpp"
	}

	includedirs
	{
		"Hazel/vendor/spdlog/include",
		"Hazel/src"
	}

	links
	{
		"Hazel"  --링크할 프로젝트를 적는다.
	}

	filter "system:windows"
		cppdialect "C++17"
		staticruntime "On"
		systemversion "latest"

		defines
		{
			"HZ_PLATFORM_WINDOWS" --전처리기 설정
		}

	filter "configurations:Debug"
		defines "HZ_DEBUG"
		symbols "On"

	filter "configurations:Release"
		defines "HZ_RELEASE"
		optimize "On"

	filter "configurations:Dist"
		defines "HZ_DIST"
		optimize "On"