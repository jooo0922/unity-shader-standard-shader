Shader "Custom/surface"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic("Metalic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _BumpMap ("Normalmap", 2d) = "bump" {} // ����Ƽ�� �������̽��κ��� �Է¹޴� �������� '_BumpMap' �̶�� ������, �ؽ��� �������̽��� �븻���� ���� ���̶�� ������. �׷��� �븻�� �ؽ��ĸ� �Է����� �����Ÿ� �ٸ� �Ϲ� �������̽��� ����� ���޽����� ���.
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Metallic;
        float _Smoothness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            /*
                �븻�� �ؽ��ĸ� ����Ƽ���� Texture Type �� �븻������ �������ָ�,
                �ش� �ؽ��İ� DXTnm ���� �������� ��ȯ��.

                �� ������ ������ �븻���� R, G ���� �ִ��� �����Ͽ�
                ���� A, G ���� �־ ������ ������.

                ���� �� A, G ���� X, Y�� ����ϰ�, Z���� �ﰢ�Լ��� �����ϴµ�,
                �̷��� ����� ��� ���ִ� ����Ƽ ���̴� ��ũ��Ʈ �Լ���
                UnpackNormal() �̶�� ���� ��.

                UnpackNormal() �Լ��� ���ڷ� float4 �� 
                (��, tex2D() �Լ��� ������ �븻�� �ؽ����� �ؼ���) �� �ް�,
                ������� float3 (��, ������ ���� X, Y, Z) �� ����.

                �� ���� SurfaceOutputStandard(���Ĵٵ� ���̴�) ����ü�� 
                Normal ���� �־��ָ� �븻���� �����!
            */
            fixed3 n = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            // o.Normal = n;
            o.Normal = float3(n.x * 2, n.y * 2, n.z); // �̷� ������ float3 n ���� �̸� ���س��� ��, n.x, y �� Ư�� ���� ���ؼ� �־��ָ� �븻���� ������ ������ �� ����.

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
