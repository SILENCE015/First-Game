Shader "Scene/Grass"
{
    Properties
    {
        _TopColor ("顶部颜色", Color) = (1.0,1.0,1.0,1.0)
        _ButtomColor ("底部颜色", Color) = (1.0,1.0,1.0,1.0)
        _BendRotationRandom ("弯曲", Range(0, 1)) = 0.2
        _BladeWidth("宽度", Range(0, 0.5)) = 0.05
        _BladeWidthRandom("随机宽度", Range(0, 1)) = 0.02
        _BladeHeight("高度", Range(0, 4)) = 0.5
        _BladeHeightRandom("随机高度", Range(0, 1)) = 0.3
        _Tessellation("密度", Range(1, 64)) = 1
        _WindDistortionMap("风贴图", 2D) = "white" {}
        _WindFrequency("风频率", Vector) = (0.05, 0.05, 0, 0)
        _WindStrength("风强度", Float) = 1
        _BladeForward("偏移量", Float) = 0.38
        _BladeCurve("弯曲程度", Range(1, 4)) = 2
        _TranslucentGain("阴影", Range(0, 1)) = 0.1
        _ShadowInt("阴影强度", Range(-0.5, 1)) = 0.1
    }

    CGINCLUDE
    #include "UnityCG.cginc" 
    #include "Lighting.cginc"
    #include "AutoLight.cginc"
    #include "Tessellation.cginc"
    #include "../Test/CustomTessellation.cginc"
    #pragma multi_compile_fwdbase_fullshadows
    

    float _BendRotationRandom;
    float _BladeHeight;
    float _BladeHeightRandom;	
    float _BladeWidth;
    float _BladeWidthRandom;
    sampler2D _WindDistortionMap;
    float4 _WindDistortionMap_ST;
    float2 _WindFrequency;
    float _WindStrength;
    float _BladeForward;
    float _BladeCurve;
    float _ShadowInt;

    #define BLADE_SEGMENTS 3

    struct VertexInput
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv0 : TEXCOORD0;
    };

    struct geometryOutput
    {
        float4 vertex : SV_POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv0 : TEXCOORD0;
        unityShadowCoord4 _ShadowCoord : TEXCOORD1;
    };

    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv0 : TEXCOORD0;
    };

    VertexOutput vert (VertexInput v)
    {
        VertexOutput o;
        o.pos = v.vertex;
        o.normal = v.normal;
        o.tangent = v.tangent;
        o.uv0 = v.uv0;
        return o;
    }

    // 从一个三维输入生成一个随机数
    float rand(float3 co)
    {
        return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
    }
    // 接收一个角度（弧度制）并返回一个围绕提供轴旋转的矩阵
    float3x3 AngleAxis3x3(float angle, float3 axis)
    {
        float c, s;
        sincos(angle, s, c);

        float t = 1 - c;
        float x = axis.x;
        float y = axis.y;
        float z = axis.z;

        return float3x3(
        t * x * x + c, t * x * y - s * z, t * x * z + s * y,
        t * x * y + s * z, t * y * y + c, t * y * z - s * x,
        t * x * z - s * y, t * y * z + s * x, t * z * z + c
        );
    }

    geometryOutput verteOutput(float3 pos, float2 uv, float3 normal)
    {
        geometryOutput o = UNITY_INITIALIZE_OUTPUT(geometryOutput, o);
        o.vertex = UnityObjectToClipPos(pos);
        o.uv0 = uv;
        o.normal = UnityObjectToWorldNormal(normal);
        o._ShadowCoord = ComputeScreenPos(o.vertex);
        #if UNITY_PASS_SHADOWCASTER
            o.vertex = UnityApplyLinearShadowBias(o.vertex);
        #endif
        return o;
    }

    geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
    {
        float3 tangentPoint = float3(width, forward, height);

        float3 tangentNormal = normalize(float3(0, -1, forward));
        float3 localNormal = mul(transformMatrix, tangentNormal);

        float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
        return verteOutput(localPosition, uv, localNormal);
    }

    [maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
    void geo(triangle VertexOutput IN[3], inout TriangleStream<geometryOutput> triStream)
    {
        geometryOutput o;

        float3 pos = IN[0].pos;
        float3 vNormal = IN[0].normal;
        float4 vTangent = IN[0].tangent;
        float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
        // TBN矩阵
        float3x3 TBN = float3x3(
        vTangent.x, vBinormal.x, vNormal.x,
        vTangent.y, vBinormal.y, vNormal.y,
        vTangent.z, vBinormal.z, vNormal.z
        );
        // 旋转
        float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
        float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
        // 大小
        float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
        float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
        // 风
        float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + frac(_WindFrequency * _Time.y);
        float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
        float3 wind = normalize(float3(windSample.x, windSample.y, 0));//Wind Vector
        float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);

        float3x3 transformationMatrix = mul(mul(mul(TBN, facingRotationMatrix),bendRotationMatrix),windRotation);
        float3x3 transformationMatrixFacing = mul(TBN, facingRotationMatrix);

        float forward = rand(pos.yyz) * _BladeForward;

        for(int i = 0; i < BLADE_SEGMENTS; i++)
        {
            float t = i / (float)BLADE_SEGMENTS;
            float segmentHeight = height * t;
            float segmentWidth = width * (1 - t);

            float segmentForward = pow(t, _BladeCurve) * forward;

            float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;
            triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, 0), transformMatrix));
            triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, 0), transformMatrix));
            // triStream.Append(vertexOutput(pos + mul(transformationMatrix, float3(0, 0, height)), float2(0.5, 1)));
        }
        triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));
    }
    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Geometry" }
        Cull off

        Pass
        {
            Tags { "LightMode" = "Forwardbase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geo
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain
            #pragma target 4.6
            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"

            float4 _TopColor;
            float4 _ButtomColor;
            float _TranslucentGain;

            fixed4 frag (geometryOutput i, fixed facing : VFACE) : SV_Target
            {
                float shadow = SHADOW_ATTENUATION(i);
                float3 normal = facing > 0 ? i.normal : -i.normal;
                float nDotl = saturate(saturate(dot(normal, _WorldSpaceLightPos0)) + _TranslucentGain) * (shadow + _ShadowInt);
                float3 ambient = ShadeSH9(float4(normal, 1));
                float4 lightIntensity = smoothstep(0, 0.01, nDotl) * _LightColor0 + float4(ambient, 1);
                float4 col = lerp(_ButtomColor, _TopColor * lightIntensity, nDotl * 0.5 + 0.5);

                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma geometry geo
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain
            #pragma target 4.6
            #pragma multi_compile_shadowcaster

            float4 frag(geometryOutput i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }

            ENDCG
        }
    }
}
