Shader "Scene/WaterFall"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("MainColor", Color) = (0.0, 0.0, 0.0, 0.0)
        _NormalTex ("Normal", 2D) = "bump" {}
        _SamplerNoise ("SamplerNoise", 2D) = "white" {}
        _WaveControl ("WaveControl", vector) = (0,0,0,0)
        _WaveTex ("WaveTexture", 2D) = "black" {}
    }
    SubShader
    {
        Tags 
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True" 
        }
        Cull off

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : COLOR;
            };

            struct v2f
            {    
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 color : TEXCOORD3;
            };

            sampler2D _MainTex; float4 _MainTex_ST;
            fixed4 _Color;
            sampler2D _NormalTex; float4 _NormalTex_ST;;
            sampler2D _SamplerNoise; float4 _SamplerNoise_ST;
            sampler2D _WaveTex; float4 _WaveTex_ST;
            fixed4 _WaveControl;;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv.y += _Time.x;
                o.color = v.color;
                o.uv1 = v.uv1;
                TANGENT_SPACE_ROTATION;
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 samplerNoise = fixed2(tex2D(_SamplerNoise, i.uv * _SamplerNoise_ST.xy).r * _WaveControl.z, 0);
                float2 samplerUV = float2(_Time.y * _WaveControl.x, 0);

                float3 normalDir = normalize(UnpackNormal(tex2D(_NormalTex, TRANSFORM_TEX(i.uv, _NormalTex) + samplerUV * 0.25 + samplerNoise)));
                float vdn = saturate(pow(dot(i.viewDir, normalDir), _WaveControl.y));

                fixed distortNoise = tex2D(_SamplerNoise, i.uv * _SamplerNoise_ST.xy + samplerUV + samplerNoise).r;
                fixed waveMask = saturate((i.color.g - distortNoise) * 30);
                fixed waveTex = tex2D(_WaveTex, i.uv * _WaveTex_ST.xy + samplerUV + samplerNoise).r * waveMask;
                i.uv.x += samplerNoise.x;
                i.uv.y += (samplerNoise.x + _Time.x);
                fixed4 col = tex2D(_MainTex, i.uv * _MainTex_ST + _Time.x) * (2 - vdn) * (1-i.color.r) + tex2D(_MainTex, i.uv1 * _MainTex_ST + _Time.x) * i.color.r;
                col.rgb += waveTex;
                col.a = 0.7;
                return col * _Color;
            }
            ENDCG
        }
    }
}
