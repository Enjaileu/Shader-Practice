Shader "Smooth Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Lower ("Lower value", float) = 0.0
        _Higher ("Higher value", float) = 1.0
    }
    SubShader
    {
        Tags 
        { 
            "Order"="Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True" 
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Lower;
            uniform float _Higher;

            //on utilise le vertexshader (vertexInput) pour créer le fragment shader(VertexOutput) en rasterizant
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                o.texcoord.zw = 0;
                return o;
            }

            // on applique le fragmentshader (vertexoutput) pour afficher les couleurs de pixels
            half4 frag(VertexOutput i):COLOR 
            {
                float4 color = tex2D(_MainTex, i.texcoord)* _Color;
                color.a = smoothstep(_Lower, _Higher, i.texcoord.x);
                return color;
            }
            ENDCG
        }
    }
}
