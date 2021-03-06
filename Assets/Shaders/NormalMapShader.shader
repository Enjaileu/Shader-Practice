Shader "Normal map Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "Order"="Opaque"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True" 
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;

            struct VertexInput
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float4 tangent: TANGENT;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
                float4 normalWorld: TEXCOORD1;
                float4 tangentWorld: TEXCOORD2;
                float3 binormalWorld: TEXCOORD3;
                float4 normalTexcoord: TEXCOORD4;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                o.texcoord.zw = 0;

                o.normalTexcoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));
                o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent));
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld)* v.tangent.w);
                
                return o;
            }

            float3 normalFromColor(float4 color){
                #if defined(UNITY_NO_DXT5nm)
                return color.xyz;

                #else
                //red channel = alpha
                float3 normal = float3(0.0, color.a, 0.0);
                normal.z = sqrt(1- dot(normal, normal));
                return normal;
                #endif
            }

            float3 worldNormalFromNormalMap(sampler2D normalMap, float2 normalTexCoord, float3 tangentWorld, float3 binormalWorld, float3 normalWorld){
                // get la couleur au pixel que nous lisons ?? partir de tangent space normal map
                float4 colorAtPixel = tex2D(normalMap, normalTexCoord);

                //valeur de la normal converti ?? partir de la couleur r??cup??r??e
                float3 normalAtPixel = normalFromColor(colorAtPixel);

                //TBN matrice
                float3x3 TBNWorld = float3x3(tangentWorld, binormalWorld, normalWorld);
                return normalize(mul(normalAtPixel, TBNWorld));
            }

            half4 frag(VertexOutput i):COLOR 
            {
                float3 worldNormalAtPixel = worldNormalFromNormalMap(_NormalMap, i.normalTexcoord.xy, i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);

                return float4(worldNormalAtPixel, 1);
            }
            ENDCG
        }
    }
}
