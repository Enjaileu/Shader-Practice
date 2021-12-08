Shader "Unlit/RedUnlitShader"
{
    Properties // va crééer des var accessibles depuis l'inspector
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM // utilise le laguage nvidia 
            #pragma vertex vert // info de compilation du shader
            #pragma fragment frag

            #include "UnityCG.cginc" // import de librairie

            struct appdata // from the app to vertex shader
            {
                // on récupère la position des vertex de la géo. On associe info de position à chaque vertex.
                float4 vertex : POSITION; 
                // on pourrait récuperer les infos d'uv aussi par exemple mais on le fait pas dans ce shader.
            };

            struct v2f //from vertex to fragment
            {
                float4 vertex : SV_POSITION;
            };

            //definition des var qui vont être utilisés dans le shader program
            fixed4 _Color;

            // SHADER PROGRAM
            v2f vert (appdata v) //v contient les vertex et leur infos associées grace au struct appadata
            {
                v2f o; // o est la transformation 2 fragment shader
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color; // return la couleur pour chaque pixel
            }
            ENDCG
        }
    }
}
