Shader "Custom/Camo RGB" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal ("Normal Map", 2D) = "bump" {}

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", 2D) = "black" {}

		_Camo1 ("Camo 1", 2D) = "white" {}
		_Camo2 ("Camo 2", 2D) = "white" {}
		_Camo3 ("Camo 3", 2D) = "white" {}

		_Color1 ("Camo Color 1", Color) = (1, 1, 1, 1)
		_Color2 ("Camo Color 2", Color) = (1, 1, 1, 1)
		_Color3 ("Camo Color 3", Color) = (1, 1, 1, 1)

		_CamoOpacity1 ("Camo Opacity 1", Range (0, 1)) = 0
		_CamoOpacity2 ("Camo Opacity 2", Range (0, 1)) = 0
		_CamoOpacity3 ("Camo Opacity 3", Range (0, 1)) = 0

	}
	SubShader {
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
		};

		sampler2D _MainTex;
		sampler2D _Normal;
		sampler2D _Metallic;
		
		fixed4 _Color;
		fixed _Glossiness;
	
		sampler2D _Camo1;
		sampler2D _Camo2;
		sampler2D _Camo3;
		
		fixed4 _Color1;
		fixed4 _Color2;
		fixed4 _Color3;

		fixed _CamoOpacity1;
		fixed _CamoOpacity2;
		fixed _CamoOpacity3;

		//Combine all camo lerp maps (black and white, where camo ought to go)
		//Make a texture out of the colored camo lerp map (assign each color to the camo and combine)
		//Lerp between albedo and colored camo by lerp map
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{			
			fixed4 albedoSample = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			fixed4 camoSample1 = tex2D (_Camo1, IN.uv_MainTex) * _CamoOpacity1;
			fixed4 camo1 = camoSample1 * _Color1;

			fixed4 camoSample2 = tex2D (_Camo2, IN.uv_MainTex) * _CamoOpacity2;
			fixed4 camo2 = camoSample2 * _Color2;

			fixed4 camoSample3 = tex2D (_Camo3, IN.uv_MainTex) * _CamoOpacity3;
			fixed4 camo3 = camoSample3 * _Color3;

			fixed4 finalCamo = camo1 + camo2 + camo3;
			fixed4 finalCamoSample = camoSample1 + camoSample2 + camoSample3;

			float4 metallicSample = tex2D(_Metallic, IN.uv_Metallic);

			o.Albedo = lerp(albedoSample, finalCamo, finalCamoSample);
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_BumpMap));
			o.Metallic = metallicSample;
			o.Smoothness = metallicSample.a * _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
