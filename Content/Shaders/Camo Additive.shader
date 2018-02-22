Shader "Custom/Camo Additive" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_CamoColor ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal ("Normal Map", 2D) = "bump" {}
		_Metallic ("Metallic", 2D) = "black" {}
		
		_Camo ("Camo", 2D) = "white" {}
		_CamoMask ("Camo Mask", 2D) = "white" {}


		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_CamoOpacity ("Camo Opacity", Range (0, 1)) = 0
		_CamoSize ("Camo Size", Range (.1, 3)) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard fullforwardshadows

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_Metallic;
			float2 uv_CamoMask;
		};

		sampler2D _MainTex;
		sampler2D _Normal;
		sampler2D _Metallic;
		
		fixed4 _Color;
		fixed4 _CamoColor;
		fixed _Glossiness;
	
		sampler2D _Camo;
		sampler2D _CamoMask;
		
		fixed _CamoOpacity;
		fixed _CamoSize;

		//Combine all camo lerp maps (black and white, where camo ought to go)
		//Make a texture out of the colored camo lerp map (assign each color to the camo and combine)
		//Lerp between albedo and colored camo by lerp map
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{	
			fixed4 albedoSample = tex2D(_MainTex, IN.uv_MainTex) * _Color;		
			float4 metallicSample = tex2D(_Metallic, IN.uv_Metallic);
			
			fixed4 camoMaskSample = tex2D(_CamoMask, IN.uv_CamoMask);
			fixed4 camoSample = tex2D(_Camo, IN.uv_MainTex / _CamoSize) * camoMaskSample * _CamoColor * _CamoOpacity;

			o.Albedo = albedoSample + camoSample; //lerp (albedoSample, camoSample, _CamoOpacity * camoMaskSample);
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_BumpMap));
			o.Metallic = metallicSample;
			o.Smoothness = metallicSample.a * _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
